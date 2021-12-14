import UIKit
import Flutter
import Firebase
import Photos
import CallKit
//import FacebookCore

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    var callObserver: CXCallObserver!
    
    let preventAnnounceView = UIView(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    
    override func application( _ application: UIApplication,didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }
        GeneratedPluginRegistrant.register(with: self)
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
//        NotificationCenter.default.addObserver(self, selector: #selector(alertPreventScreenCapture(notification:)), name: UIApplication.userDidTakeScreenshotNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(hideScreen(notification:)), name: UIScreen.capturedDidChangeNotification, object: nil)
                
//        if #available(iOS 14, *) {
//            PHPhotoLibrary.requestAuthorization(for: .readWrite) { authorizationStatus in
//                OperationQueue.main.addOperation { [self] in
//                    self.handleStatus(status: authorizationStatus)
//                }
//            }
//        } else {
//            PHPhotoLibrary.requestAuthorization { authorizationStatus in
//                OperationQueue.main.addOperation {
//                    self.handleStatus(status: authorizationStatus)
//                }
//            }
//        }
        callObserver = CXCallObserver()
        callObserver.setDelegate(self, queue: nil) 
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
//    override func application(_ app: UIApplication,open url: URL,options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//           AppDelegate.shared.application(app,open: url,sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
//               annotation: options[UIApplication.OpenURLOptionsKey.annotation]
//           )
//       }
//    func handleStatus(status: PHAuthorizationStatus) {
//        switch status {
//        case .authorized:
//            print("state is Authorized")
//        case .limited:
//            print("state is limited")
//        case .denied, .notDetermined, .restricted:
//            print("state is Denied")
//        @unknown default:
//            break
//        }
//    }
    override func applicationDidBecomeActive(_ application: UIApplication) {
        self.window.isHidden = false
    }
    override func applicationWillResignActive(_ application: UIApplication) {
        self.window.isHidden = true
        //  UIApplication.shared.ignoreSnapshotOnNextApplicationLaunch()
    }
    
    @objc private func hideScreen(notification:Notification) -> Void {
        configurePreventView()
        if UIScreen.main.isCaptured {
            window?.addSubview(preventAnnounceView)
        } else {
            preventAnnounceView.removeFromSuperview()
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
    
//    private func didTakeScreenshot() {
//        let fetchScreenshotOptions = PHFetchOptions()
//        fetchScreenshotOptions.sortDescriptors?[0] = Foundation.NSSortDescriptor(key: "creationDate", ascending: true)
//        let fetchScreenshotResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchScreenshotOptions)
//
//        guard let lastestScreenshot = fetchScreenshotResult.lastObject else { return }
//        PHPhotoLibrary.shared().performChanges {
//            PHAssetChangeRequest.deleteAssets([lastestScreenshot] as NSFastEnumeration)
//        } completionHandler: { (success, errorMessage) in
//            if !success, let errorMessage = errorMessage {
//                print(errorMessage.localizedDescription)
//            }
//        }
//    }
    
    @objc private func alertPreventScreenCapture(notification:Notification) -> Void {
        sleep(2) //sleep until new screenshot added in photos otherwise it asks to delete previous one  and not current ss
        //didTakeScreenshot()
        //delete ss from iphone
        if UIScreen.main.isCaptured {
            window?.addSubview(preventAnnounceView)
        } 
    }
    //    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        if touches.first != nil {
    //            // ...
    //            print("ss taken !! Prevent it !")
    //        }
    //        super.touchesBegan(touches, with: event)
    //    }
}
extension AppDelegate: CXCallObserverDelegate {
    
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        if call.hasEnded == true {
            print("Call Disconnected")
        }
        
        if call.isOutgoing == true && call.hasConnected == false {
            print("call Dialing")
        }
        
        if call.isOutgoing == false && call.hasConnected == false && call.hasEnded == false {
            print("call Incoming")
        }
        
        if call.hasConnected == true && call.hasEnded == false {
            print("Call Connected")
        }
    }
}
