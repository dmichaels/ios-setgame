import SwiftUI
import UIKit
import GameKit

@main
struct SetGameApp: App {

    @StateObject private var settings: Settings = Settings();
    @StateObject private var feedback: Feedback;
    @StateObject private var table: Table<TableCard>;

    init() {
        // GameCenterManager.shared.authenticatePlayer();
        let shared_settings: Settings = Settings();
        _settings = StateObject(wrappedValue: shared_settings);
        _feedback  = StateObject(wrappedValue: Feedback(sounds: shared_settings.sounds,
                                                        haptics: shared_settings.haptics));
        _table     = StateObject(wrappedValue: Table(settings: shared_settings));
        print("GC authenticated:", GKLocalPlayer.local.isAuthenticated)
        print("GC alias:", GKLocalPlayer.local.displayName)
        print("GC id:", GKLocalPlayer.local.gamePlayerID)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(self.table)
                .environmentObject(self.settings)
                .environmentObject(self.feedback)
        }
    }
}
