#import "PPSSignatureView.h"

#define STROKE_WIDTH_MIN 2.0
#define STROKE_WIDTH_MAX 7.0
#define STROKE_WIDTH_SMOOTHING 0.5

#define VELOCITY_CLAMP_MIN 20
#define VELOCITY_CLAMP_MAX 5000

#define QUADRATIC_DISTANCE_TOLERANCE 3.0

static float clamp(float min, float max, float value) { return fmaxf(min, fminf(max, value)); }

@interface PPSSignatureView () {
    CGContextRef _bitmapContext;
    CGFloat _penThickness;
    CGFloat _previousThickness;

    CGPoint _previousPoint;
    CGPoint _previousMidPoint;

    UIColor *_bgColor;
    UIColor *_penColor;
}

@end

@implementation PPSSignatureView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _bgColor = [UIColor whiteColor];
    _penColor = [UIColor blackColor];
    _penThickness = (STROKE_WIDTH_MIN + STROKE_WIDTH_MAX) / 2.0;
    _previousThickness = _penThickness;
    _previousPoint = CGPointMake(-100, -100);
    _previousMidPoint = CGPointMake(-100, -100);

    self.backgroundColor = _bgColor;
    self.opaque = NO;
    self.hasSignature = NO;

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.maximumNumberOfTouches = 1;
    pan.minimumNumberOfTouches = 1;
    pan.cancelsTouchesInView = YES;
    [self addGestureRecognizer:pan];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tap.cancelsTouchesInView = YES;
    [self addGestureRecognizer:tap];

    UILongPressGestureRecognizer *longer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longer.cancelsTouchesInView = YES;
    [self addGestureRecognizer:longer];
}

- (void)dealloc {
    [self releaseBitmapContext];
}

- (void)releaseBitmapContext {
    if (_bitmapContext) {
        CGContextRelease(_bitmapContext);
        _bitmapContext = NULL;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (self.bounds.size.width <= 0 || self.bounds.size.height <= 0) {
        return;
    }

    // Recreate bitmap context when bounds change
    CGImageRef oldImage = NULL;
    if (_bitmapContext) {
        oldImage = CGBitmapContextCreateImage(_bitmapContext);
        [self releaseBitmapContext];
    }

    [self ensureBitmapContext];

    // Redraw old content into new context if we had one
    if (oldImage) {
        CGContextDrawImage(_bitmapContext, self.bounds, oldImage);
        CGImageRelease(oldImage);
    }
}

#pragma mark - Bitmap Context

- (void)ensureBitmapContext {
    if (_bitmapContext) return;

    CGFloat scale = [UIScreen mainScreen].scale;
    NSInteger width = (NSInteger)(self.bounds.size.width * scale);
    NSInteger height = (NSInteger)(self.bounds.size.height * scale);

    if (width <= 0 || height <= 0) return;

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    _bitmapContext = CGBitmapContextCreate(
        NULL,
        width,
        height,
        8,
        width * 4,
        colorSpace,
        kCGImageAlphaPremultipliedLast
    );
    CGColorSpaceRelease(colorSpace);

    if (!_bitmapContext) return;

    // Scale for retina
    CGContextScaleCTM(_bitmapContext, scale, scale);

    // Flip coordinate system (CGContext is bottom-up, UIKit is top-down)
    CGContextTranslateCTM(_bitmapContext, 0, self.bounds.size.height);
    CGContextScaleCTM(_bitmapContext, 1.0, -1.0);

    // Fill with background color
    [self fillBitmapWithBackgroundColor];
}

- (void)fillBitmapWithBackgroundColor {
    if (!_bitmapContext) return;

    CGContextSaveGState(_bitmapContext);
    CGContextSetFillColorWithColor(_bitmapContext, _bgColor.CGColor);
    CGContextFillRect(_bitmapContext, self.bounds);
    CGContextRestoreGState(_bitmapContext);
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    if (!_bitmapContext) return;

    CGImageRef image = CGBitmapContextCreateImage(_bitmapContext);
    if (image) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        if (ctx) {
            CGContextDrawImage(ctx, self.bounds, image);
        }
        CGImageRelease(image);
    }
}

#pragma mark - Gesture Recognizers

- (void)tap:(UITapGestureRecognizer *)t {
    if (t.state != UIGestureRecognizerStateRecognized) return;

    CGPoint l = [t locationInView:self];

    [self ensureBitmapContext];
    if (!_bitmapContext) return;

    CGFloat radius = _penThickness > 0 ? _penThickness : (STROKE_WIDTH_MIN + STROKE_WIDTH_MAX) / 2.0;

    CGContextSaveGState(_bitmapContext);
    CGContextSetFillColorWithColor(_bitmapContext, _penColor.CGColor);
    CGRect dotRect = CGRectMake(l.x - radius / 2.0, l.y - radius / 2.0, radius, radius);
    CGContextFillEllipseInRect(_bitmapContext, dotRect);
    CGContextRestoreGState(_bitmapContext);

    self.hasSignature = YES;
    [self setNeedsDisplay];
}

- (void)longPress:(UILongPressGestureRecognizer *)lp {
    if (lp.state == UIGestureRecognizerStateBegan) {
        [self erase];
    }
}

- (void)pan:(UIPanGestureRecognizer *)p {
    CGPoint v = [p velocityInView:self];
    CGPoint l = [p locationInView:self];

    CGFloat distance = 0.0;
    if (_previousPoint.x > -50) {
        distance = sqrtf((l.x - _previousPoint.x) * (l.x - _previousPoint.x) +
                         (l.y - _previousPoint.y) * (l.y - _previousPoint.y));
    }

    CGFloat velocityMagnitude = sqrtf(v.x * v.x + v.y * v.y);
    CGFloat clampedVelocityMagnitude = clamp(VELOCITY_CLAMP_MIN, VELOCITY_CLAMP_MAX, velocityMagnitude);
    CGFloat normalizedVelocity = (clampedVelocityMagnitude - VELOCITY_CLAMP_MIN) / (VELOCITY_CLAMP_MAX - VELOCITY_CLAMP_MIN);

    CGFloat lowPassFilterAlpha = STROKE_WIDTH_SMOOTHING;
    CGFloat newThickness = (STROKE_WIDTH_MAX - STROKE_WIDTH_MIN) * (1 - normalizedVelocity) + STROKE_WIDTH_MIN;
    _penThickness = _penThickness * lowPassFilterAlpha + newThickness * (1 - lowPassFilterAlpha);

    [self ensureBitmapContext];
    if (!_bitmapContext) return;

    if ([p state] == UIGestureRecognizerStateBegan) {
        _previousPoint = l;
        _previousMidPoint = l;
        _previousThickness = _penThickness;

        self.hasSignature = YES;
        if (self.onDraggedBlock) {
            self.onDraggedBlock();
        }

    } else if ([p state] == UIGestureRecognizerStateChanged) {
        CGPoint mid = CGPointMake((l.x + _previousPoint.x) / 2.0, (l.y + _previousPoint.y) / 2.0);

        if (distance > QUADRATIC_DISTANCE_TOLERANCE) {
            int segments = (int)(distance / 1.5);

            CGFloat startPenThickness = _previousThickness;
            CGFloat endPenThickness = _penThickness;
            _previousThickness = _penThickness;

            for (int i = 0; i < segments; i++) {
                CGFloat t = (CGFloat)i / (CGFloat)segments;
                CGFloat thickness = startPenThickness + ((endPenThickness - startPenThickness) / segments) * i;

                // Quadratic Bezier interpolation
                CGFloat a = pow((1.0 - t), 2.0);
                CGFloat b = 2.0 * t * (1.0 - t);
                CGFloat c = pow(t, 2.0);

                CGPoint quadPoint = CGPointMake(
                    a * _previousMidPoint.x + b * _previousPoint.x + c * mid.x,
                    a * _previousMidPoint.y + b * _previousPoint.y + c * mid.y
                );

                [self strokeSegmentFrom:_previousPoint to:quadPoint thickness:thickness];
            }
        } else if (distance > 1.0) {
            [self strokeSegmentFrom:_previousPoint to:l thickness:_penThickness];
            _previousThickness = _penThickness;
        }

        _previousPoint = l;
        _previousMidPoint = mid;

    } else if (p.state == UIGestureRecognizerStateEnded || p.state == UIGestureRecognizerStateCancelled) {
        // Draw final point
        [self strokeSegmentFrom:_previousPoint to:l thickness:_penThickness];
    }

    [self setNeedsDisplay];
}

- (void)strokeSegmentFrom:(CGPoint)from to:(CGPoint)to thickness:(CGFloat)thickness {
    if (!_bitmapContext) return;

    CGContextSaveGState(_bitmapContext);

    CGContextSetStrokeColorWithColor(_bitmapContext, _penColor.CGColor);
    CGContextSetLineWidth(_bitmapContext, thickness);
    CGContextSetLineCap(_bitmapContext, kCGLineCapRound);
    CGContextSetLineJoin(_bitmapContext, kCGLineJoinRound);

    CGContextMoveToPoint(_bitmapContext, from.x, from.y);
    CGContextAddLineToPoint(_bitmapContext, to.x, to.y);
    CGContextStrokePath(_bitmapContext);

    CGContextRestoreGState(_bitmapContext);
}

#pragma mark - Erase

- (void)erase {
    self.hasSignature = NO;
    _previousPoint = CGPointMake(-100, -100);
    _previousMidPoint = CGPointMake(-100, -100);
    _penThickness = (STROKE_WIDTH_MIN + STROKE_WIDTH_MAX) / 2.0;
    _previousThickness = _penThickness;

    if (_bitmapContext) {
        [self fillBitmapWithBackgroundColor];
    }

    [self setNeedsDisplay];
}

#pragma mark - Color Properties

- (void)setStrokeColor:(UIColor *)strokeColor {
    _strokeColor = strokeColor;
    _penColor = strokeColor ?: [UIColor blackColor];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    _bgColor = backgroundColor ?: [UIColor whiteColor];

    if (_bitmapContext && !self.hasSignature) {
        [self fillBitmapWithBackgroundColor];
        [self setNeedsDisplay];
    }
}

#pragma mark - Image Export

- (UIImage *)snapshot {
    if (!_bitmapContext) return nil;

    CGImageRef cgImage = CGBitmapContextCreateImage(_bitmapContext);
    if (!cgImage) return nil;

    UIImage *image = [UIImage imageWithCGImage:cgImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    CGImageRelease(cgImage);
    return image;
}

- (UIImage *)rotateImage:(UIImage *)sourceImage clockwise:(BOOL)clockwise {
    CGSize size = sourceImage.size;
    UIGraphicsBeginImageContext(CGSizeMake(size.height, size.width));
    [[UIImage imageWithCGImage:[sourceImage CGImage]
                         scale:1.0
                   orientation:clockwise ? UIImageOrientationRight : UIImageOrientationLeft]
     drawInRect:CGRectMake(0, 0, size.height, size.width)];

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

- (UIImage *)reduceImage:(UIImage *)image toSize:(CGSize)newSize {
    CGSize scaledSize = newSize;
    float scaleFactor = 1.0;

    if (image.size.width > image.size.height) {
        scaleFactor = image.size.width / image.size.height;
        scaledSize.width = newSize.width;
        scaledSize.height = newSize.height / scaleFactor;
    } else {
        scaleFactor = image.size.height / image.size.width;
        scaledSize.height = newSize.height;
        scaledSize.width = newSize.width / scaleFactor;
    }

    UIGraphicsBeginImageContext(scaledSize);
    CGRect scaledImageRect = CGRectMake(0.0, 0.0, scaledSize.width, scaledSize.height);
    [image drawInRect:scaledImageRect];

    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return scaledImage;
}

- (UIImage *)signatureImage {
    return [self signatureImage:NO withSquare:NO];
}

- (UIImage *)signatureImage:(BOOL)rotatedImage {
    return [self signatureImage:rotatedImage withSquare:NO];
}

- (UIImage *)signatureImage:(BOOL)rotatedImage withSquare:(BOOL)square {
    if (!self.hasSignature)
        return nil;

    UIImage *signatureImg;
    UIImage *snapshotImg = [self snapshot];
    [self erase];

    if (square) {
        signatureImg = [self reduceImage:snapshotImg toSize:CGSizeMake(400.0f, 400.0f)];
    } else {
        signatureImg = snapshotImg;
    }

    if (rotatedImage) {
        signatureImg = [self rotateImage:signatureImg clockwise:NO];
    }

    return signatureImg;
}

@end
