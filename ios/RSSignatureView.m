#import "RSSignatureView.h"
#import <React/RCTConvert.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PPSSignatureView.h"

#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)

@implementation RSSignatureView {
	CAShapeLayer *_border;
	BOOL _loaded;
	UIButton *saveButton;
	UIButton *clearButton;
	UILabel *titleLabel;
	BOOL _rotateClockwise;
	BOOL _square;
	BOOL _showBorder;
	BOOL _showNativeButtons;
	BOOL _showTitleLabel;
	UIColor *_backgroundColor;
	UIColor *_strokeColor;
}

@synthesize sign;

- (instancetype)init
{
	_showBorder = YES;
	_showNativeButtons = YES;
	_showTitleLabel = YES;
	_backgroundColor = UIColor.whiteColor;
	_strokeColor = UIColor.blackColor;
	if ((self = [super init])) {
		_border = [CAShapeLayer layer];
		_border.strokeColor = [UIColor blackColor].CGColor;
		_border.fillColor = nil;
		_border.lineDashPattern = @[@4, @2];

		[self.layer addSublayer:_border];
	}

	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	if (!_loaded) {

		CGSize screen = self.bounds.size;

		sign = [[PPSSignatureView alloc]
						initWithFrame:CGRectMake(0, 0, screen.width, screen.height)];
		sign.backgroundColor = _backgroundColor;
		sign.strokeColor = _strokeColor;

		__weak RSSignatureView *weakSelf = self;
		sign.onDraggedBlock = ^{
			[weakSelf fireDragEvent];
		};

		[self addSubview:sign];

		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {

			if (_showTitleLabel) {
				titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 24)];
				[titleLabel setCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height - 120)];

				[titleLabel setText:@"x_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _"];
				[titleLabel setLineBreakMode:NSLineBreakByClipping];
				[titleLabel setTextAlignment:NSTextAlignmentCenter];
				[titleLabel setTextColor:[UIColor colorWithRed:200/255.f green:200/255.f blue:200/255.f alpha:1.f]];
				[sign addSubview:titleLabel];
			}

			if (_showNativeButtons) {
				saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
				[saveButton setLineBreakMode:NSLineBreakByClipping];
				[saveButton addTarget:self action:@selector(onSaveButtonPressed)
				            forControlEvents:UIControlEventTouchUpInside];
				[saveButton setTitle:@"Save" forState:UIControlStateNormal];

				CGSize buttonSize = CGSizeMake(80, 55.0);

				saveButton.frame = CGRectMake(sign.bounds.size.width - buttonSize.width,
				                              0, buttonSize.width, buttonSize.height);
				[saveButton setBackgroundColor:[UIColor colorWithRed:250/255.f green:250/255.f blue:250/255.f alpha:1.f]];
				[sign addSubview:saveButton];

				clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
				[clearButton setLineBreakMode:NSLineBreakByClipping];
				[clearButton addTarget:self action:@selector(onClearButtonPressed)
				             forControlEvents:UIControlEventTouchUpInside];
				[clearButton setTitle:@"Reset" forState:UIControlStateNormal];

				clearButton.frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
				[clearButton setBackgroundColor:[UIColor colorWithRed:250/255.f green:250/255.f blue:250/255.f alpha:1.f]];
				[sign addSubview:clearButton];
			}
		}
		else {

			if (_showTitleLabel) {
				titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.height - 80, 24)];
				[titleLabel setCenter:CGPointMake(40, self.bounds.size.height/2)];
				[titleLabel setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90))];
				[titleLabel setText:@"x_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _"];
				[titleLabel setLineBreakMode:NSLineBreakByClipping];
				[titleLabel setTextAlignment:NSTextAlignmentLeft];
				[titleLabel setTextColor:[UIColor colorWithRed:200/255.f green:200/255.f blue:200/255.f alpha:1.f]];
				[sign addSubview:titleLabel];
			}

			if (_showNativeButtons) {
				saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
				[saveButton setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90))];
				[saveButton setLineBreakMode:NSLineBreakByClipping];
				[saveButton addTarget:self action:@selector(onSaveButtonPressed)
				            forControlEvents:UIControlEventTouchUpInside];
				[saveButton setTitle:@"Save" forState:UIControlStateNormal];

				CGSize buttonSize = CGSizeMake(55, 80.0);

				saveButton.frame = CGRectMake(sign.bounds.size.width - buttonSize.width, sign.bounds.size.height - buttonSize.height, buttonSize.width, buttonSize.height);
				[saveButton setBackgroundColor:[UIColor colorWithRed:250/255.f green:250/255.f blue:250/255.f alpha:1.f]];
				[sign addSubview:saveButton];

				clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
				[clearButton setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90))];
				[clearButton setLineBreakMode:NSLineBreakByClipping];
				[clearButton addTarget:self action:@selector(onClearButtonPressed)
				             forControlEvents:UIControlEventTouchUpInside];
				[clearButton setTitle:@"Reset" forState:UIControlStateNormal];

				clearButton.frame = CGRectMake(sign.bounds.size.width - buttonSize.width, 0, buttonSize.width, buttonSize.height);
				[clearButton setBackgroundColor:[UIColor colorWithRed:250/255.f green:250/255.f blue:250/255.f alpha:1.f]];
				[sign addSubview:clearButton];
			}
		}

	}
	_loaded = true;
	_border.path = _showBorder ? [UIBezierPath bezierPathWithRect:self.bounds].CGPath : nil;
	_border.frame = self.bounds;
}

- (void)setRotateClockwise:(BOOL)rotateClockwise {
	_rotateClockwise = rotateClockwise;
}

- (void)setSquare:(BOOL)square {
	_square = square;
}

- (void)setShowBorder:(BOOL)showBorder {
	_showBorder = showBorder;
}

- (void)setShowNativeButtons:(BOOL)showNativeButtons {
	_showNativeButtons = showNativeButtons;
}

- (void)setShowTitleLabel:(BOOL)showTitleLabel {
	_showTitleLabel = showTitleLabel;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
	_backgroundColor = backgroundColor;
}

- (void)setStrokeColor:(UIColor *)strokeColor {
	_strokeColor = strokeColor;
}

- (void)onSaveButtonPressed {
	[self saveImage];
}

- (void)saveImage {
	saveButton.hidden = YES;
	clearButton.hidden = YES;
	UIImage *signImage = [self.sign signatureImage:_rotateClockwise withSquare:_square];

	saveButton.hidden = NO;
	clearButton.hidden = NO;

	NSError *error;

	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths firstObject];
	NSString *tempPath = [documentsDirectory stringByAppendingFormat:@"/signature.png"];

	if ([[NSFileManager defaultManager] fileExistsAtPath:tempPath]) {
		[[NSFileManager defaultManager] removeItemAtPath:tempPath error:&error];
		if (error) {
			NSLog(@"Error: %@", error.debugDescription);
		}
	}

	NSData *imageData = UIImagePNGRepresentation(signImage);
	BOOL isSuccess = [imageData writeToFile:tempPath atomically:YES];
	if (isSuccess) {
		NSString *base64Encoded = [imageData base64EncodedStringWithOptions:0];

		if (self.onSaveEvent) {
			self.onSaveEvent(@{
				@"pathName": tempPath,
				@"encoded": base64Encoded
			});
		}
	}
}

- (void)fireDragEvent {
	if (self.onDragEvent) {
		self.onDragEvent(@{@"dragged": @YES});
	}
}

- (void)onClearButtonPressed {
	[self erase];
}

- (void)erase {
	[self.sign erase];
}

@end
