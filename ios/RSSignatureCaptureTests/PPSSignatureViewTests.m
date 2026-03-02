#import <XCTest/XCTest.h>
#import "PPSSignatureView.h"

@interface PPSSignatureViewTests : XCTestCase
@property (nonatomic, strong) PPSSignatureView *signatureView;
@end

@implementation PPSSignatureViewTests

- (void)setUp {
    [super setUp];
    self.signatureView = [[PPSSignatureView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
}

- (void)tearDown {
    self.signatureView = nil;
    [super tearDown];
}

- (void)testInitWithFrame_returnsNonNil {
    XCTAssertNotNil(self.signatureView);
}

- (void)testInitWithFrame_setsCorrectFrame {
    CGRect expected = CGRectMake(0, 0, 320, 480);
    XCTAssertTrue(CGRectEqualToRect(self.signatureView.frame, expected),
                  @"Frame should be (0, 0, 320, 480)");
}

- (void)testInitialHasSignature_isNO {
    XCTAssertFalse(self.signatureView.hasSignature,
                   @"hasSignature should be NO initially");
}

- (void)testErase_resetsHasSignature {
    // Simulate having a signature by setting it directly via KVC
    [self.signatureView setValue:@YES forKey:@"hasSignature"];
    XCTAssertTrue(self.signatureView.hasSignature);

    [self.signatureView erase];
    XCTAssertFalse(self.signatureView.hasSignature,
                   @"hasSignature should be NO after erase");
}

- (void)testSetStrokeColor_storesColor {
    UIColor *red = [UIColor redColor];
    self.signatureView.strokeColor = red;
    XCTAssertEqualObjects(self.signatureView.strokeColor, red,
                          @"strokeColor should be red after setting");
}

- (void)testSetBackgroundColor_storesColor {
    UIColor *blue = [UIColor blueColor];
    [self.signatureView setBackgroundColor:blue];
    // backgroundColor is stored internally as _bgColor and also set via super
    XCTAssertEqualObjects(self.signatureView.backgroundColor, blue,
                          @"backgroundColor should be blue after setting");
}

- (void)testSignatureImage_returnsNilWhenNoSignature {
    UIImage *image = [self.signatureView signatureImage];
    XCTAssertNil(image,
                 @"signatureImage should return nil when hasSignature is NO");
}

@end
