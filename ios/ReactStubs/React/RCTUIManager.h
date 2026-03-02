#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class RCTUIManager;

typedef void (^RCTViewManagerUIBlock)(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry);

@interface RCTUIManager : NSObject
- (void)addUIBlock:(RCTViewManagerUIBlock)block;
@end
