#import <XCTest/XCTest.h>
#import "RSSignatureView.h"
#import "PPSSignatureView.h"

@interface RSSignatureViewTests : XCTestCase
@property (nonatomic, strong) RSSignatureView *rsView;
@end

@implementation RSSignatureViewTests

- (void)setUp {
    [super setUp];
    self.rsView = [[RSSignatureView alloc] init];
}

- (void)tearDown {
    self.rsView = nil;
    [super tearDown];
}

- (void)testInit_returnsNonNil {
    XCTAssertNotNil(self.rsView);
}

- (void)testDefaults_showBorderYES {
    // Access via KVC since _showBorder is an ivar
    NSNumber *showBorder = [self.rsView valueForKey:@"showBorder"];
    XCTAssertTrue(showBorder.boolValue, @"showBorder should default to YES");
}

- (void)testDefaults_showNativeButtonsYES {
    NSNumber *showNativeButtons = [self.rsView valueForKey:@"showNativeButtons"];
    XCTAssertTrue(showNativeButtons.boolValue, @"showNativeButtons should default to YES");
}

- (void)testDefaults_showTitleLabelYES {
    NSNumber *showTitleLabel = [self.rsView valueForKey:@"showTitleLabel"];
    XCTAssertTrue(showTitleLabel.boolValue, @"showTitleLabel should default to YES");
}

- (void)testSetRotateClockwise_storesValue {
    [self.rsView setRotateClockwise:YES];
    NSNumber *val = [self.rsView valueForKey:@"rotateClockwise"];
    XCTAssertTrue(val.boolValue, @"rotateClockwise should be YES after setting");
}

- (void)testSetSquare_storesValue {
    [self.rsView setSquare:YES];
    NSNumber *val = [self.rsView valueForKey:@"square"];
    XCTAssertTrue(val.boolValue, @"square should be YES after setting");
}

- (void)testErase_callsSignErase {
    // Give the view a frame and trigger layout so `sign` gets created
    self.rsView.frame = CGRectMake(0, 0, 320, 480);
    [self.rsView layoutSubviews];

    XCTAssertNotNil(self.rsView.sign, @"sign should be created after layout");

    // Simulate a signature via KVC on the inner PPSSignatureView
    [self.rsView.sign setValue:@YES forKey:@"hasSignature"];
    XCTAssertTrue(self.rsView.sign.hasSignature);

    [self.rsView erase];
    XCTAssertFalse(self.rsView.sign.hasSignature,
                   @"erase should clear the inner signature view");
}

- (void)testFireDragEvent_callsOnDragEventBlock {
    __block BOOL called = NO;
    __block NSDictionary *receivedBody = nil;

    self.rsView.onDragEvent = ^(NSDictionary *body) {
        called = YES;
        receivedBody = body;
    };

    [self.rsView fireDragEvent];

    XCTAssertTrue(called, @"onDragEvent block should be called");
    XCTAssertEqualObjects(receivedBody[@"dragged"], @YES,
                          @"dragged should be YES");
}

@end
