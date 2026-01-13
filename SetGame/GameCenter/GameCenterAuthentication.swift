import GameKit
import UIKit

@MainActor
enum GameCenterAuthentication {

    static func authenticate() {
        let player = GKLocalPlayer.local

        player.authenticateHandler = { viewController, error in
            if let error {
                print("GC auth error:", error.localizedDescription)
            }

            if let vc = viewController {
                // iOS is asking us to present a login UI
                guard let top = TopViewController.get() else {
                    print("GC: couldn't find a view controller to present auth UI")
                    return
                }
                top.present(vc, animated: true)
                return
            }

            // No UI provided → either already authenticated or cannot authenticate right now
            print("GC isAuthenticated:", player.isAuthenticated)
            if player.isAuthenticated {
                print("GC displayName:", player.displayName)
                print("GC playerID:", player.gamePlayerID)
            } else {
                print("GC not authenticated (user signed out / restricted / declined / etc.)")
            }
        }

        // Optional "poke" so GameKit evaluates state immediately
        _ = player.isAuthenticated
    }
}
