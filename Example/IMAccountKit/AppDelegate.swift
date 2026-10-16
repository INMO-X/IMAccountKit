import IMAccountKit
import IMBaseKit
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        IMLaunchManager.shared.launch(forKey: IMLaunchKey.sdk)
        IMUtils.set(uid: IMAccountManager.shared.accountInfo?.userId,
                    token: IMAccountManager.shared.accountInfo?.accessToken)
        return true
    }
}
