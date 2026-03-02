#import <UIKit/UIKit.h>

@interface PPSSignatureView : UIView

@property (strong, nonatomic) UIColor *strokeColor;
@property (assign, nonatomic) BOOL hasSignature;
@property (nonatomic, copy) void (^onDraggedBlock)(void);

- (void)erase;

- (UIImage *)signatureImage;
- (UIImage *)signatureImage:(BOOL)rotatedImage;
- (UIImage *)signatureImage:(BOOL)rotatedImage withSquare:(BOOL)square;

@end
