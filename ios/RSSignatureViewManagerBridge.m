#import <React/RCTViewManager.h>

@interface RCT_EXTERN_MODULE(RSSignatureViewManager, RCTViewManager)
RCT_EXPORT_VIEW_PROPERTY(rotateClockwise, BOOL)
RCT_EXPORT_VIEW_PROPERTY(square, BOOL)
RCT_EXPORT_VIEW_PROPERTY(showBorder, BOOL)
RCT_EXPORT_VIEW_PROPERTY(showNativeButtons, BOOL)
RCT_EXPORT_VIEW_PROPERTY(showTitleLabel, BOOL)
RCT_EXPORT_VIEW_PROPERTY(backgroundColor, UIColor)
RCT_EXPORT_VIEW_PROPERTY(strokeColor, UIColor)
RCT_EXPORT_VIEW_PROPERTY(onSaveEvent, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onDragEvent, RCTDirectEventBlock)
RCT_EXTERN_METHOD(saveImage:(nonnull NSNumber *)reactTag)
RCT_EXTERN_METHOD(resetImage:(nonnull NSNumber *)reactTag)
@end
