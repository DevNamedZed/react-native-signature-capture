#import <Foundation/Foundation.h>

@class RCTUIManager;

@interface RCTBridge : NSObject
@property (nonatomic, strong) RCTUIManager *uiManager;
@end
