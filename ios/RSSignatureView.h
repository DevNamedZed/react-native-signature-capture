#import "PPSSignatureView.h"
#import <UIKit/UIKit.h>
#import <React/RCTView.h>

@interface RSSignatureView : RCTView

@property (nonatomic, strong) PPSSignatureView *sign;
@property (nonatomic, copy) RCTDirectEventBlock onSaveEvent;
@property (nonatomic, copy) RCTDirectEventBlock onDragEvent;

- (void)saveImage;
- (void)erase;
- (void)fireDragEvent;

- (void)setRotateClockwise:(BOOL)rotateClockwise;
- (void)setSquare:(BOOL)square;
- (void)setShowBorder:(BOOL)showBorder;
- (void)setShowNativeButtons:(BOOL)showNativeButtons;
- (void)setShowTitleLabel:(BOOL)showTitleLabel;
- (void)setStrokeColor:(UIColor *)strokeColor;

@end
