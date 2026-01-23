import SwiftUI

@main
struct SetGameApp: App {

    @StateObject private var settings: Settings = Settings();
    @StateObject private var feedback: Feedback;
    @StateObject private var table: Table;

    init() {
        // let multiPlayerSender: MultiPlayerSender? = Defaults.gameCenter ? GameCenterSender() : nil;
        let shared_settings: Settings = Settings();
        _settings = StateObject(wrappedValue: shared_settings);
        _feedback = StateObject(wrappedValue: Feedback(sounds: shared_settings.sounds,
                                                       haptics: shared_settings.haptics));
        _table = StateObject(wrappedValue: Table(settings: shared_settings /*, multiplayer: multiPlayerSender */ ));
        // let x = RelayTransport(player: "A", receiver: _table);
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(self.table)
                .environmentObject(self.settings)
                .environmentObject(self.feedback)
                .task {
                    await GameCenterAuthentication.authenticate()
                }
        }
    }
}
