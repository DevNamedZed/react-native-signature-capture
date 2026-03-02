import XCTest

class PPSSignatureViewTests: XCTestCase {

    var signatureView: PPSSignatureView!

    override func setUp() {
        super.setUp()
        signatureView = PPSSignatureView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
    }

    override func tearDown() {
        signatureView = nil
        super.tearDown()
    }

    func testInitWithFrame_returnsNonNil() {
        XCTAssertNotNil(signatureView)
    }

    func testInitWithFrame_setsCorrectFrame() {
        let expected = CGRect(x: 0, y: 0, width: 320, height: 480)
        XCTAssertTrue(signatureView.frame.equalTo(expected),
                      "Frame should be (0, 0, 320, 480)")
    }

    func testInitialHasSignature_isNO() {
        XCTAssertFalse(signatureView.hasSignature,
                       "hasSignature should be NO initially")
    }

    func testErase_resetsHasSignature() {
        signatureView.hasSignature = true
        XCTAssertTrue(signatureView.hasSignature)

        signatureView.erase()
        XCTAssertFalse(signatureView.hasSignature,
                       "hasSignature should be NO after erase")
    }

    func testSetStrokeColor_storesColor() {
        let red = UIColor.red
        signatureView.strokeColor = red
        XCTAssertEqual(signatureView.strokeColor, red,
                       "strokeColor should be red after setting")
    }

    func testSetBackgroundColor_storesColor() {
        let blue = UIColor.blue
        signatureView.backgroundColor = blue
        XCTAssertEqual(signatureView.backgroundColor, blue,
                       "backgroundColor should be blue after setting")
    }

    func testSignatureImage_returnsNilWhenNoSignature() {
        let image = signatureView.signatureImage()
        XCTAssertNil(image,
                     "signatureImage should return nil when hasSignature is NO")
    }
}
