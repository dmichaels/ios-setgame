import SwiftUI

@main
struct SetGameApp: App {

    @StateObject private var settings: Settings = Settings();
    @StateObject private var feedback: Feedback;
    @StateObject private var table: Table;
        // public static var gameCenterTransport: GameCenter.Transport? = nil;

    init() {
        // SetGameApp.gameCenterTransport = Defaults.gameCenter ? GameCenter.HttpTransport(player: "A") : nil;
        let settings: Settings = Settings();
        _settings = StateObject(wrappedValue: settings);
        _feedback = StateObject(wrappedValue: Feedback(sounds: settings.sounds,
                                                       haptics: settings.haptics));
        // _table = StateObject(wrappedValue: Table(settings: settings, gameCenterSender: SetGameApp.gameCenterTransport));
        _table = StateObject(wrappedValue: Table(settings: settings, gameCenterSender: GameCenter.HttpTransport.instance));
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(self.table)
                .environmentObject(self.settings)
                .environmentObject(self.feedback)
                .task {
                    await GameCenterAuthentication.authenticate();
                    // SetGameApp.gameCenterTransport?.configure(handler: self.table);
                    GameCenter.HttpTransport.instance.configure(handler: self.table);
                }
        }
    }
}
