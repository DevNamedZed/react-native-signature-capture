import UIKit

@objcMembers
class RSSignatureView: RCTView {

    private(set) var sign: PPSSignatureView?
    var onSaveEvent: RCTDirectEventBlock?
    var onDragEvent: RCTDirectEventBlock?

    // MARK: - State

    private var border: CAShapeLayer
    private var loaded = false
    private var saveButton: UIButton?
    private var clearButton: UIButton?
    private var titleLabel: UILabel?
    var rotateClockwise = false
    var square = false
    var showBorder = true
    var showNativeButtons = true {
        didSet {
            saveButton?.isHidden = !showNativeButtons
            clearButton?.isHidden = !showNativeButtons
        }
    }
    var showTitleLabel = true {
        didSet {
            titleLabel?.isHidden = !showTitleLabel
        }
    }
    private var _backgroundColor: UIColor = .white
    var strokeColor: UIColor = .black {
        didSet {
            sign?.strokeColor = strokeColor
        }
    }

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        border = CAShapeLayer()
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        border = CAShapeLayer()
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        border.strokeColor = UIColor.black.cgColor
        border.fillColor = nil
        border.lineDashPattern = [4, 2]
        layer.addSublayer(border)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if !loaded {
            let screen = bounds.size

            let signView = PPSSignatureView(frame: CGRect(x: 0, y: 0,
                                                          width: screen.width,
                                                          height: screen.height))
            signView.backgroundColor = _backgroundColor
            signView.strokeColor = strokeColor

            sign = signView

            weak var weakSelf = self
            signView.onDraggedBlock = {
                weakSelf?.fireDragEvent()
            }

            addSubview(signView)

            let isPad = UIDevice.current.userInterfaceIdiom == .pad

            if isPad {
                if showTitleLabel {
                    let label = UILabel(frame: CGRect(x: 0, y: 0,
                                                      width: bounds.size.width, height: 24))
                    label.center = CGPoint(x: bounds.size.width / 2,
                                           y: bounds.size.height - 120)
                    label.text = "x_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _"
                    label.lineBreakMode = .byClipping
                    label.textAlignment = .center
                    label.textColor = UIColor(red: 200/255, green: 200/255,
                                              blue: 200/255, alpha: 1)
                    titleLabel = label
                    signView.addSubview(label)
                }

                if showNativeButtons {
                    let buttonSize = CGSize(width: 80, height: 55)

                    let save = UIButton(type: .system)
                    save.titleLabel?.lineBreakMode = .byClipping
                    save.addTarget(self, action: #selector(onSaveButtonPressed),
                                   for: .touchUpInside)
                    save.setTitle("Save", for: .normal)
                    save.frame = CGRect(x: signView.bounds.size.width - buttonSize.width,
                                        y: 0,
                                        width: buttonSize.width,
                                        height: buttonSize.height)
                    save.backgroundColor = UIColor(red: 250/255, green: 250/255,
                                                   blue: 250/255, alpha: 1)
                    saveButton = save
                    signView.addSubview(save)

                    let clear = UIButton(type: .system)
                    clear.titleLabel?.lineBreakMode = .byClipping
                    clear.addTarget(self, action: #selector(onClearButtonPressed),
                                    for: .touchUpInside)
                    clear.setTitle("Reset", for: .normal)
                    clear.frame = CGRect(x: 0, y: 0,
                                         width: buttonSize.width,
                                         height: buttonSize.height)
                    clear.backgroundColor = UIColor(red: 250/255, green: 250/255,
                                                    blue: 250/255, alpha: 1)
                    clearButton = clear
                    signView.addSubview(clear)
                }
            } else {
                let degreesToRadians = { (x: CGFloat) -> CGFloat in .pi * x / 180.0 }

                if showTitleLabel {
                    let label = UILabel(frame: CGRect(x: 0, y: 0,
                                                      width: bounds.size.height - 80, height: 24))
                    label.center = CGPoint(x: 40, y: bounds.size.height / 2)
                    label.transform = CGAffineTransform(rotationAngle: degreesToRadians(90))
                    label.text = "x_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _"
                    label.lineBreakMode = .byClipping
                    label.textAlignment = .left
                    label.textColor = UIColor(red: 200/255, green: 200/255,
                                              blue: 200/255, alpha: 1)
                    titleLabel = label
                    signView.addSubview(label)
                }

                if showNativeButtons {
                    let buttonSize = CGSize(width: 55, height: 80)

                    let save = UIButton(type: .system)
                    save.transform = CGAffineTransform(rotationAngle: degreesToRadians(90))
                    save.titleLabel?.lineBreakMode = .byClipping
                    save.addTarget(self, action: #selector(onSaveButtonPressed),
                                   for: .touchUpInside)
                    save.setTitle("Save", for: .normal)
                    save.frame = CGRect(
                        x: signView.bounds.size.width - buttonSize.width,
                        y: signView.bounds.size.height - buttonSize.height,
                        width: buttonSize.width,
                        height: buttonSize.height
                    )
                    save.backgroundColor = UIColor(red: 250/255, green: 250/255,
                                                   blue: 250/255, alpha: 1)
                    saveButton = save
                    signView.addSubview(save)

                    let clear = UIButton(type: .system)
                    clear.transform = CGAffineTransform(rotationAngle: degreesToRadians(90))
                    clear.titleLabel?.lineBreakMode = .byClipping
                    clear.addTarget(self, action: #selector(onClearButtonPressed),
                                    for: .touchUpInside)
                    clear.setTitle("Reset", for: .normal)
                    clear.frame = CGRect(
                        x: signView.bounds.size.width - buttonSize.width,
                        y: 0,
                        width: buttonSize.width,
                        height: buttonSize.height
                    )
                    clear.backgroundColor = UIColor(red: 250/255, green: 250/255,
                                                    blue: 250/255, alpha: 1)
                    clearButton = clear
                    signView.addSubview(clear)
                }
            }
        }

        loaded = true
        sign?.frame = bounds
        border.path = showBorder ? UIBezierPath(rect: bounds).cgPath : nil
        border.frame = bounds
    }

    // MARK: - Property Overrides

    override var backgroundColor: UIColor? {
        get { _backgroundColor }
        set {
            _backgroundColor = newValue ?? .white
            super.backgroundColor = _backgroundColor
            sign?.backgroundColor = _backgroundColor
        }
    }

    // MARK: - Actions

    @objc private func onSaveButtonPressed() {
        saveImage()
    }

    func saveImage() {
        saveButton?.isHidden = true
        clearButton?.isHidden = true
        let signImage = sign?.signatureImage(clockwise: rotateClockwise, square: square)

        saveButton?.isHidden = false
        clearButton?.isHidden = false

        guard let signImage = signImage else { return }

        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        guard let documentsDirectory = paths.first else { return }
        let tempPath = documentsDirectory + "/signature.png"

        if FileManager.default.fileExists(atPath: tempPath) {
            try? FileManager.default.removeItem(atPath: tempPath)
        }

        guard let imageData = signImage.pngData() else { return }
        let isSuccess = (try? imageData.write(to: URL(fileURLWithPath: tempPath))) != nil

        if isSuccess {
            let base64Encoded = imageData.base64EncodedString()
            onSaveEvent?([
                "pathName": tempPath,
                "encoded": base64Encoded
            ])
        }
    }

    func fireDragEvent() {
        onDragEvent?(["dragged": true])
    }

    @objc private func onClearButtonPressed() {
        erase()
    }

    func erase() {
        sign?.erase()
    }
}
