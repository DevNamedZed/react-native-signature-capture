import UIKit

private let strokeWidthMin: CGFloat = 2.0
private let strokeWidthMax: CGFloat = 7.0
private let strokeWidthSmoothing: CGFloat = 0.5

private let velocityClampMin: CGFloat = 20
private let velocityClampMax: CGFloat = 5000

private let quadraticDistanceTolerance: CGFloat = 3.0

@objcMembers
class PPSSignatureView: UIView {

    var strokeColor: UIColor? {
        didSet {
            penColor = strokeColor ?? .black
        }
    }

    var hasSignature: Bool = false

    var onDraggedBlock: (() -> Void)?

    // MARK: - Private state

    private var bitmapContext: CGContext?
    private var penThickness: CGFloat = (strokeWidthMin + strokeWidthMax) / 2.0
    private var previousThickness: CGFloat = (strokeWidthMin + strokeWidthMax) / 2.0

    private var previousPoint = CGPoint(x: -100, y: -100)
    private var previousMidPoint = CGPoint(x: -100, y: -100)

    private var bgColor: UIColor = .white
    private var penColor: UIColor = .black

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        bgColor = .white
        penColor = .black
        penThickness = (strokeWidthMin + strokeWidthMax) / 2.0
        previousThickness = penThickness
        previousPoint = CGPoint(x: -100, y: -100)
        previousMidPoint = CGPoint(x: -100, y: -100)

        backgroundColor = bgColor
        isOpaque = false
        hasSignature = false

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.maximumNumberOfTouches = 1
        pan.minimumNumberOfTouches = 1
        pan.cancelsTouchesInView = true
        addGestureRecognizer(pan)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tap.cancelsTouchesInView = true
        addGestureRecognizer(tap)

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.cancelsTouchesInView = true
        addGestureRecognizer(longPress)
    }

    deinit {
        bitmapContext = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard bounds.size.width > 0, bounds.size.height > 0 else { return }

        var oldImage: CGImage?
        if let ctx = bitmapContext {
            oldImage = ctx.makeImage()
            bitmapContext = nil
        }

        ensureBitmapContext()

        if let oldImage = oldImage, let ctx = bitmapContext {
            ctx.draw(oldImage, in: bounds)
        }
    }

    // MARK: - Bitmap Context

    private func ensureBitmapContext() {
        guard bitmapContext == nil else { return }

        let scale = UIScreen.main.scale
        let width = Int(bounds.size.width * scale)
        let height = Int(bounds.size.height * scale)

        guard width > 0, height > 0 else { return }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return }

        bitmapContext = ctx

        ctx.scaleBy(x: scale, y: scale)
        ctx.translateBy(x: 0, y: bounds.size.height)
        ctx.scaleBy(x: 1.0, y: -1.0)

        fillBitmapWithBackgroundColor()
    }

    private func fillBitmapWithBackgroundColor() {
        guard let ctx = bitmapContext else { return }
        ctx.saveGState()
        ctx.setFillColor(bgColor.cgColor)
        ctx.fill(bounds)
        ctx.restoreGState()
    }

    // MARK: - Drawing

    override func draw(_ rect: CGRect) {
        guard let bitmapCtx = bitmapContext,
              let image = bitmapCtx.makeImage(),
              let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.draw(image, in: bounds)
    }

    // MARK: - Gesture Recognizers

    @objc private func handleTap(_ t: UITapGestureRecognizer) {
        guard t.state == .recognized else { return }

        let l = t.location(in: self)

        ensureBitmapContext()
        guard let ctx = bitmapContext else { return }

        let radius = penThickness > 0 ? penThickness : (strokeWidthMin + strokeWidthMax) / 2.0

        ctx.saveGState()
        ctx.setFillColor(penColor.cgColor)
        let dotRect = CGRect(x: l.x - radius / 2.0, y: l.y - radius / 2.0,
                             width: radius, height: radius)
        ctx.fillEllipse(in: dotRect)
        ctx.restoreGState()

        hasSignature = true
        setNeedsDisplay()
    }

    @objc private func handleLongPress(_ lp: UILongPressGestureRecognizer) {
        if lp.state == .began {
            erase()
        }
    }

    @objc private func handlePan(_ p: UIPanGestureRecognizer) {
        let v = p.velocity(in: self)
        let l = p.location(in: self)

        var distance: CGFloat = 0.0
        if previousPoint.x > -50 {
            distance = sqrt((l.x - previousPoint.x) * (l.x - previousPoint.x) +
                            (l.y - previousPoint.y) * (l.y - previousPoint.y))
        }

        let velocityMagnitude = sqrt(v.x * v.x + v.y * v.y)
        let clampedVelocity = min(velocityClampMax, max(velocityClampMin, velocityMagnitude))
        let normalizedVelocity = (clampedVelocity - velocityClampMin) / (velocityClampMax - velocityClampMin)

        let newThickness = (strokeWidthMax - strokeWidthMin) * (1 - normalizedVelocity) + strokeWidthMin
        penThickness = penThickness * strokeWidthSmoothing + newThickness * (1 - strokeWidthSmoothing)

        ensureBitmapContext()
        guard bitmapContext != nil else { return }

        switch p.state {
        case .began:
            previousPoint = l
            previousMidPoint = l
            previousThickness = penThickness

            hasSignature = true
            onDraggedBlock?()

        case .changed:
            let mid = CGPoint(x: (l.x + previousPoint.x) / 2.0,
                              y: (l.y + previousPoint.y) / 2.0)

            if distance > quadraticDistanceTolerance {
                let segments = Int(distance / 1.5)
                let startPenThickness = previousThickness
                let endPenThickness = penThickness
                previousThickness = penThickness

                for i in 0..<segments {
                    let t = CGFloat(i) / CGFloat(segments)
                    let thickness = startPenThickness +
                        ((endPenThickness - startPenThickness) / CGFloat(segments)) * CGFloat(i)

                    let a = pow(1.0 - t, 2.0)
                    let b = 2.0 * t * (1.0 - t)
                    let c = pow(t, 2.0)

                    let quadPoint = CGPoint(
                        x: a * previousMidPoint.x + b * previousPoint.x + c * mid.x,
                        y: a * previousMidPoint.y + b * previousPoint.y + c * mid.y
                    )

                    strokeSegment(from: previousPoint, to: quadPoint, thickness: thickness)
                }
            } else if distance > 1.0 {
                strokeSegment(from: previousPoint, to: l, thickness: penThickness)
                previousThickness = penThickness
            }

            previousPoint = l
            previousMidPoint = mid

        case .ended, .cancelled:
            strokeSegment(from: previousPoint, to: l, thickness: penThickness)

        default:
            break
        }

        setNeedsDisplay()
    }

    private func strokeSegment(from: CGPoint, to: CGPoint, thickness: CGFloat) {
        guard let ctx = bitmapContext else { return }

        ctx.saveGState()
        ctx.setStrokeColor(penColor.cgColor)
        ctx.setLineWidth(thickness)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)
        ctx.move(to: from)
        ctx.addLine(to: to)
        ctx.strokePath()
        ctx.restoreGState()
    }

    // MARK: - Erase

    func erase() {
        hasSignature = false
        previousPoint = CGPoint(x: -100, y: -100)
        previousMidPoint = CGPoint(x: -100, y: -100)
        penThickness = (strokeWidthMin + strokeWidthMax) / 2.0
        previousThickness = penThickness

        if bitmapContext != nil {
            fillBitmapWithBackgroundColor()
        }

        setNeedsDisplay()
    }

    // MARK: - Color Properties

    override var backgroundColor: UIColor? {
        didSet {
            bgColor = backgroundColor ?? .white
            if bitmapContext != nil && !hasSignature {
                fillBitmapWithBackgroundColor()
                setNeedsDisplay()
            }
        }
    }

    // MARK: - Image Export

    private func snapshot() -> UIImage? {
        guard let ctx = bitmapContext, let cgImage = ctx.makeImage() else { return nil }
        return UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
    }

    private func rotateImage(_ sourceImage: UIImage, clockwise: Bool) -> UIImage {
        guard let cgImage = sourceImage.cgImage else { return sourceImage }
        let size = sourceImage.size
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size.height, height: size.width))
        return renderer.image { _ in
            UIImage(
                cgImage: cgImage,
                scale: 1.0,
                orientation: clockwise ? .right : .left
            ).draw(in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        }
    }

    private func reduceImage(_ image: UIImage, to newSize: CGSize) -> UIImage {
        var scaledSize = newSize

        if image.size.width > image.size.height {
            let scaleFactor = image.size.width / image.size.height
            scaledSize.width = newSize.width
            scaledSize.height = newSize.height / scaleFactor
        } else {
            let scaleFactor = image.size.height / image.size.width
            scaledSize.height = newSize.height
            scaledSize.width = newSize.width / scaleFactor
        }

        let renderer = UIGraphicsImageRenderer(size: scaledSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: scaledSize))
        }
    }

    func signatureImage() -> UIImage? {
        return signatureImage(rotated: false, square: false)
    }

    func signatureImage(rotated: Bool) -> UIImage? {
        return signatureImage(rotated: rotated, square: false)
    }

    func signatureImage(rotated: Bool, square: Bool) -> UIImage? {
        guard hasSignature else { return nil }

        guard let snapshotImg = snapshot() else { return nil }
        erase()

        var signatureImg: UIImage

        if square {
            signatureImg = reduceImage(snapshotImg, to: CGSize(width: 400, height: 400))
        } else {
            signatureImg = snapshotImg
        }

        if rotated {
            signatureImg = rotateImage(signatureImg, clockwise: false)
        }

        return signatureImg
    }
}
