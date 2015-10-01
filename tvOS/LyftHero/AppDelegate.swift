import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    /// Returns the main ChallengeViewController instance (always shown on screen).
    static var challengeViewController: ChallengeViewController? {
        let window = UIApplication.sharedApplication().keyWindow
        return window?.rootViewController as? ChallengeViewController
    }
}
