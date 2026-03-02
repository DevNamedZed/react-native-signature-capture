import XCTest

class RSSignatureViewManagerTests: XCTestCase {

    var manager: RSSignatureViewManager!

    override func setUp() {
        super.setUp()
        manager = RSSignatureViewManager()
    }

    override func tearDown() {
        manager = nil
        super.tearDown()
    }

    func testModuleName_returnsRSSignatureView() {
        XCTAssertEqual(RSSignatureViewManager.moduleName(), "RSSignatureView",
                       "moduleName should return RSSignatureView")
    }

    func testView_returnsRSSignatureViewInstance() {
        let view = manager.view()
        XCTAssertNotNil(view)
        XCTAssertTrue(view is RSSignatureView,
                      "view should return an RSSignatureView instance")
    }

    func testRequiresMainQueueSetup_returnsYES() {
        XCTAssertTrue(RSSignatureViewManager.requiresMainQueueSetup(),
                      "requiresMainQueueSetup should return YES")
    }

    func testMethodQueue_returnsMainQueue() {
        let queue = manager.methodQueue()
        XCTAssertTrue(queue === DispatchQueue.main,
                      "methodQueue should return the main queue")
    }
}
