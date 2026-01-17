import UIKit

extension UIApplication {
    var topMostViewController: UIViewController? {
        guard
            let windowScene = connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
            let window = windowScene.windows.first(where: { $0.isKeyWindow }),
            var top = window.rootViewController
        else {
            return nil
        }
        while true {
            if let presented = top.presentedViewController {
                top = presented
            } else if let nav = top as? UINavigationController, let visible = nav.visibleViewController {
                top = visible
            } else if let tab = top as? UITabBarController, let selected = tab.selectedViewController {
                top = selected
            } else {
                break
            }
        }
        return top
    }
}
