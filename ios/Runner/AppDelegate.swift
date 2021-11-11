import UIKit
import Flutter
import Photos

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    let preventAnnounceView = UIView(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    GeneratedPluginRegistrant.register(with: self)
      
    NotificationCenter.default.addObserver(self, selector: #selector(alertPreventScreenCapture(notification:)), name: UIApplication.userDidTakeScreenshotNotification, object: nil)
      
    NotificationCenter.default.addObserver(self, selector: #selector(hideScreen(notification:)), name: UIScreen.capturedDidChangeNotification, object: nil)
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
//    override func applicationWillEnterForeground(_ application: UIApplication) {
//        NotificationCenter.default.addObserver(self, selector: #selector(alertPreventScreenCapture(notification:)), name: UIApplication.userDidTakeScreenshotNotification, object: nil)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(hideScreen(notification:)), name: UIScreen.capturedDidChangeNotification, object: nil)
//    }
    @objc private func hideScreen(notification:Notification) -> Void {
      configurePreventView()
      if UIScreen.main.isCaptured {
        window?.addSubview(preventAnnounceView)
      } else {
        preventAnnounceView.removeFromSuperview()
        //alertPreventScreenRecord()
      }
    }
    
    private func configurePreventView() {
      preventAnnounceView.backgroundColor = .black
      let preventAnnounceLabel = configurePreventAnnounceLabel()
      preventAnnounceView.addSubview(preventAnnounceLabel)
    }
    
    private func configurePreventAnnounceLabel() -> UILabel {
      let preventAnnounceLabel = UILabel()
      preventAnnounceLabel.text = "Can't record screen"
      preventAnnounceLabel.font = .boldSystemFont(ofSize: 30)
      preventAnnounceLabel.numberOfLines = 0
      preventAnnounceLabel.textColor = .white
      preventAnnounceLabel.textAlignment = .center
      preventAnnounceLabel.sizeToFit()
      preventAnnounceLabel.center.x = self.preventAnnounceView.center.x
      preventAnnounceLabel.center.y = self.preventAnnounceView.center.y
      
      return preventAnnounceLabel
    }
    
//    private func alertPreventScreenRecord() {
//      let preventRecordAlert = UIAlertController(title: "caution", message: "📵 Can't record screen", preferredStyle: .alert)
//      preventRecordAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//      self.window?.rootViewController!.present(preventRecordAlert, animated: true, completion: nil)
//    }
    
    private func didTakeScreenshot() {
      let fetchScreenshotOptions = PHFetchOptions()
      fetchScreenshotOptions.sortDescriptors?[0] = Foundation.NSSortDescriptor(key: "creationDate", ascending: true)
      let fetchScreenshotResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchScreenshotOptions)
      
      guard let lastestScreenshot = fetchScreenshotResult.lastObject else { return }
      PHPhotoLibrary.shared().performChanges {
        PHAssetChangeRequest.deleteAssets([lastestScreenshot] as NSFastEnumeration)
      } completionHandler: { (success, errorMessage) in
        if !success, let errorMessage = errorMessage {
          print(errorMessage.localizedDescription)
        }
      }
    }
    
    @objc private func alertPreventScreenCapture(notification:Notification) -> Void {
     // let preventCaptureAlert = UIAlertController(title: "caution", message: "📵 Can't record screen", preferredStyle: .alert)
      //preventCaptureAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [self] _ in
        sleep(2) //sleep until new screenshot added in photos otherwise it asks to delete previous one  and not current ss
        didTakeScreenshot()
//      }))
//      preventCaptureAlert.addAction(UIAlertAction(title: "no", style: .destructive, handler: { [self] _ in
//        alertCautionNotDeleteScreenCapture()
//      }))
//      self.window?.rootViewController!.present(preventCaptureAlert, animated: true, completion: nil)
    }
}
