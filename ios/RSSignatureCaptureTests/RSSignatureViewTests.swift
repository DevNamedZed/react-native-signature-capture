import XCTest

class RSSignatureViewTests: XCTestCase {

    var rsView: RSSignatureView!

    override func setUp() {
        super.setUp()
        rsView = RSSignatureView()
    }

    override func tearDown() {
        rsView = nil
        super.tearDown()
    }

    func testInit_returnsNonNil() {
        XCTAssertNotNil(rsView)
    }

    func testDefaults_showBorderYES() {
        XCTAssertTrue(rsView.showBorder, "showBorder should default to YES")
    }

    func testDefaults_showNativeButtonsYES() {
        XCTAssertTrue(rsView.showNativeButtons, "showNativeButtons should default to YES")
    }

    func testDefaults_showTitleLabelYES() {
        XCTAssertTrue(rsView.showTitleLabel, "showTitleLabel should default to YES")
    }

    func testSetRotateClockwise_storesValue() {
        rsView.rotateClockwise = true
        XCTAssertTrue(rsView.rotateClockwise, "rotateClockwise should be YES after setting")
    }

    func testSetSquare_storesValue() {
        rsView.square = true
        XCTAssertTrue(rsView.square, "square should be YES after setting")
    }

    func testErase_callsSignErase() {
        rsView.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        rsView.layoutSubviews()

        XCTAssertNotNil(rsView.sign, "sign should be created after layout")

        rsView.sign?.hasSignature = true
        XCTAssertTrue(rsView.sign?.hasSignature == true)

        rsView.erase()
        XCTAssertFalse(rsView.sign?.hasSignature ?? true,
                       "erase should clear the inner signature view")
    }

    func testSaveImage_firesOnSaveEventWithPayload() {
        rsView.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        rsView.layoutSubviews()

        XCTAssertNotNil(rsView.sign, "sign should be created after layout")

        rsView.sign?.hasSignature = true
        rsView.sign?.layoutSubviews()

        var receivedBody: [AnyHashable: Any]?
        rsView.onSaveEvent = { body in
            receivedBody = body
        }

        rsView.saveImage()

        XCTAssertNotNil(receivedBody, "onSaveEvent should be called")
        XCTAssertNotNil(receivedBody?["pathName"] as? String,
                        "payload should contain pathName")
        let encoded = receivedBody?["encoded"] as? String
        XCTAssertNotNil(encoded, "payload should contain encoded")
        XCTAssertFalse(encoded?.isEmpty ?? true,
                       "encoded should not be empty")
    }

    func testFireDragEvent_callsOnDragEventBlock() {
        var called = false
        var receivedBody: [AnyHashable: Any]?

        rsView.onDragEvent = { body in
            called = true
            receivedBody = body
        }

        rsView.fireDragEvent()

        XCTAssertTrue(called, "onDragEvent block should be called")
        XCTAssertEqual(receivedBody?["dragged"] as? Bool, true,
                       "dragged should be YES")
    }
}
