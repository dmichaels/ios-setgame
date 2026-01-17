import Foundation
import GameKit
import UIKit

@MainActor
final class GameCenterManager: NSObject, ObservableObject {

    static let shared = GameCenterManager()
    private override init() { super.init() }

    @Published private(set) var isAuthenticated: Bool = GKLocalPlayer.local.isAuthenticated
    @Published private(set) var displayName: String = GKLocalPlayer.local.isAuthenticated ? GKLocalPlayer.local.displayName : ""
    @Published var showOpenSettingsAlert: Bool = false
    @Published private(set) var lastAuthError: String = ""

    private var handlerInstalled = false

    func refreshAuthState(tag: String = "") {
        let p = GKLocalPlayer.local
        isAuthenticated = p.isAuthenticated
        displayName = p.isAuthenticated ? p.displayName : ""
        if !tag.isEmpty { print("GC> state(\(tag)) auth=\(isAuthenticated) name=\(displayName)") }
    }

    func signInUserInitiated() {
        print("GC> Sign In tapped")
        installAuthHandlerIfNeeded()
        showOpenSettingsAlert = false
        lastAuthError = ""
        _ = GKLocalPlayer.local.isAuthenticated   // poke
    }

    private func installAuthHandlerIfNeeded() {
        guard !handlerInstalled else { return }
        handlerInstalled = true

        GKLocalPlayer.local.authenticateHandler = { [weak self] vc, error in
            guard let self else { return }
            defer { self.refreshAuthState(tag: "handler") }

            if let error {
                self.lastAuthError = error.localizedDescription
                print("GC> auth error: \(error)")
            }

            if let vc {
                guard let top = UIApplication.shared.topMostViewController else {
                    print("GC> no top VC")
                    return
                }
                if top.presentedViewController != nil {
                    print("GC> already presenting; not presenting auth UI")
                    return
                }
                print("GC> presenting GC login UI")
                top.present(vc, animated: true)
                return
            }

            if GKLocalPlayer.local.isAuthenticated {
                print("GC> authenticated as \(GKLocalPlayer.local.displayName)")
                self.showOpenSettingsAlert = false
            } else {
                print("GC> not authenticated; offer Settings fallback")
                self.showOpenSettingsAlert = true
            }
        }
    }

    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
