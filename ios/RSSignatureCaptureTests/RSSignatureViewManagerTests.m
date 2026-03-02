#import <XCTest/XCTest.h>
#import "RSSignatureViewManager.h"
#import "RSSignatureView.h"

@interface RSSignatureViewManagerTests : XCTestCase
@property (nonatomic, strong) RSSignatureViewManager *manager;
@end

@implementation RSSignatureViewManagerTests

- (void)setUp {
    [super setUp];
    self.manager = [[RSSignatureViewManager alloc] init];
}

- (void)tearDown {
    self.manager = nil;
    [super tearDown];
}

- (void)testView_returnsRSSignatureViewInstance {
    UIView *view = [self.manager view];
    XCTAssertNotNil(view);
    XCTAssertTrue([view isKindOfClass:[RSSignatureView class]],
                  @"view should return an RSSignatureView instance");
}

- (void)testRequiresMainQueueSetup_returnsYES {
    XCTAssertTrue([RSSignatureViewManager requiresMainQueueSetup],
                  @"requiresMainQueueSetup should return YES");
}

- (void)testMethodQueue_returnsMainQueue {
    dispatch_queue_t queue = [self.manager methodQueue];
    XCTAssertEqual(queue, dispatch_get_main_queue(),
                   @"methodQueue should return the main queue");
}

@end
