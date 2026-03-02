#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class RCTBridge;

@interface RCTViewManager : NSObject
@property (nonatomic, weak) RCTBridge *bridge;
- (UIView *)view;
- (dispatch_queue_t)methodQueue;
+ (NSString *)moduleName;
+ (BOOL)requiresMainQueueSetup;
@end

#define RCT_EXPORT_MODULE(js_name) \
  + (NSString *)moduleName { return @#js_name; }

#define RCT_EXPORT_VIEW_PROPERTY(name, type)

#define RCT_EXPORT_METHOD(method) - (void)method

#define RCT_EXTERN_MODULE(objc_name, objc_supername) objc_name : objc_supername
#define RCT_EXTERN_METHOD(method)
