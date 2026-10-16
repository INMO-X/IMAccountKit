import IMAccountKit
import IMUIKit
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let root = storyboard.instantiateInitialViewController() ?? ViewController()
        window.rootViewController = IMBaseNavigationController(rootViewController: root)
        window.makeKeyAndVisible()
        self.window = window
    }
}
