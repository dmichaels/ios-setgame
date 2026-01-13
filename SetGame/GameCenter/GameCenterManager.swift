import Foundation
import GameKit
import UIKit

@MainActor
final class GameCenterManager: NSObject, ObservableObject, GKMatchmakerViewControllerDelegate {

    static let shared = GameCenterManager()

    @Published private(set) var isAuthenticated: Bool = GKLocalPlayer.local.isAuthenticated
    @Published private(set) var displayName: String = GKLocalPlayer.local.isAuthenticated ? GKLocalPlayer.local.displayName : ""

    // SwiftUI uses this to show your fallback alert
    @Published var showSettingsAlert: Bool = false
    @Published var settingsAlertMessage: String = ""

    private var authHandlerInstalled = false

    override init() {
        super.init()
        installAuthHandlerIfNeeded()
        refresh()
    }

    // Call this from your button tap.
    func playWithFriends(minPlayers: Int = 2, maxPlayers: Int = 4) {
        installAuthHandlerIfNeeded()
        refresh()

        // If already authenticated, go straight to matchmaking.
        if GKLocalPlayer.local.isAuthenticated {
            presentMatchmaker(minPlayers: minPlayers, maxPlayers: maxPlayers)
            return
        }

        // Otherwise: "poke" GameKit to run authenticateHandler.
        // If iOS wants to show UI, it will give us a VC in the handler.
        // If it doesn't, we'll fall back to Settings from the handler.
        _ = GKLocalPlayer.local.isAuthenticated
    }

    func openGameCenterSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Internals

    private func installAuthHandlerIfNeeded() {
        guard !authHandlerInstalled else { return }
        authHandlerInstalled = true

        let player = GKLocalPlayer.local

        player.authenticateHandler = { [weak self] vc, error in
            guard let self else { return }

            if let error {
                print("GC auth error:", error.localizedDescription)
            }

            // If GameKit provides UI, *present it*.
            if let vc {
                guard let topVC = UIApplication.shared.topMostViewController else {
                    print("GC: no top VC to present auth UI")
                    return
                }
                // If something else is being presented, don't fight it.
                if topVC.presentedViewController != nil {
                    print("GC: top VC already presenting; not presenting GC auth UI")
                    return
                }
                topVC.present(vc, animated: true)
                return
            }

            // No UI was provided. Update state.
            self.refresh()

            // Still not authenticated => show fallback alert to Settings.
            if !player.isAuthenticated {
                self.settingsAlertMessage =
                """
                To play with friends, please sign in to Game Center.

                Go to Settings → Game Center and sign in, then return to the app.
                """
                self.showSettingsAlert = true
            }
        }
    }

    private func refresh() {
        isAuthenticated = GKLocalPlayer.local.isAuthenticated
        displayName = GKLocalPlayer.local.isAuthenticated ? GKLocalPlayer.local.displayName : ""
        print("GC state -> auth=\(isAuthenticated) name=\(displayName)")
    }

    private func presentMatchmaker(minPlayers: Int, maxPlayers: Int) {
        let request = GKMatchRequest()
        request.minPlayers = minPlayers
        request.maxPlayers = maxPlayers

        guard let mmvc = GKMatchmakerViewController(matchRequest: request) else {
            print("GC: could not create matchmaker VC")
            return
        }
        mmvc.matchmakerDelegate = self

        guard let topVC = UIApplication.shared.topMostViewController else {
            print("GC: no top VC to present matchmaker")
            return
        }
        if topVC.presentedViewController != nil {
            print("GC: top VC already presenting; not presenting matchmaker")
            return
        }

        topVC.present(mmvc, animated: true)
    }

    // MARK: - GKMatchmakerViewControllerDelegate

    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        viewController.dismiss(animated: true)
    }

    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        print("GC matchmaker failed:", error.localizedDescription)
        viewController.dismiss(animated: true)
    }

    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        print("GC match found. Players:", match.players.count)
        viewController.dismiss(animated: true)
        // Next step later: store match, set delegate, exchange messages, etc.
    }
}
