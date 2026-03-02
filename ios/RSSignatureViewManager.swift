import UIKit

@objc(RSSignatureViewManager)
@objcMembers
class RSSignatureViewManager: RCTViewManager {

    override class func moduleName() -> String! {
        return "RSSignatureView"
    }

    override func methodQueue() -> DispatchQueue! {
        return .main
    }

    override func view() -> UIView! {
        return RSSignatureView()
    }

    override class func requiresMainQueueSetup() -> Bool {
        return true
    }

    @objc func saveImage(_ reactTag: NSNumber) {
        bridge?.uiManager.addUIBlock { _, viewRegistry in
            guard let view = viewRegistry?[reactTag] as? RSSignatureView else { return }
            view.saveImage()
        }
    }

    @objc func resetImage(_ reactTag: NSNumber) {
        bridge?.uiManager.addUIBlock { _, viewRegistry in
            guard let view = viewRegistry?[reactTag] as? RSSignatureView else { return }
            view.erase()
        }
    }
}
