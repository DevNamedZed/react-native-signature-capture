#import "RSSignatureViewManager.h"
#import "RSSignatureView.h"
#import <React/RCTBridge.h>
#import <React/RCTUIManager.h>

@implementation RSSignatureViewManager

RCT_EXPORT_MODULE(RSSignatureView)

RCT_EXPORT_VIEW_PROPERTY(rotateClockwise, BOOL)
RCT_EXPORT_VIEW_PROPERTY(square, BOOL)
RCT_EXPORT_VIEW_PROPERTY(showBorder, BOOL)
RCT_EXPORT_VIEW_PROPERTY(showNativeButtons, BOOL)
RCT_EXPORT_VIEW_PROPERTY(showTitleLabel, BOOL)
RCT_EXPORT_VIEW_PROPERTY(backgroundColor, UIColor)
RCT_EXPORT_VIEW_PROPERTY(strokeColor, UIColor)
RCT_EXPORT_VIEW_PROPERTY(onSaveEvent, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onDragEvent, RCTDirectEventBlock)

- (dispatch_queue_t)methodQueue
{
	return dispatch_get_main_queue();
}

- (UIView *)view
{
	RSSignatureView *signView = [[RSSignatureView alloc] init];
	return signView;
}

+ (BOOL)requiresMainQueueSetup
{
	return YES;
}

RCT_EXPORT_METHOD(saveImage:(nonnull NSNumber *)reactTag) {
	[self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
		RSSignatureView *view = (RSSignatureView *)viewRegistry[reactTag];
		if ([view isKindOfClass:[RSSignatureView class]]) {
			[view saveImage];
		}
	}];
}

RCT_EXPORT_METHOD(resetImage:(nonnull NSNumber *)reactTag) {
	[self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
		RSSignatureView *view = (RSSignatureView *)viewRegistry[reactTag];
		if ([view isKindOfClass:[RSSignatureView class]]) {
			[view erase];
		}
	}];
}

@end
