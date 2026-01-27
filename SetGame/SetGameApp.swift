import SwiftUI

@main
struct SetGameApp: App {

    @StateObject private var settings: Settings = Settings();
    @StateObject private var feedback: Feedback;
    @StateObject private var table: Table;

    init() {
        let settings: Settings = Settings();
        _settings = StateObject(wrappedValue: settings);
        _feedback = StateObject(wrappedValue: Feedback(sounds: settings.sounds,
                                                       haptics: settings.haptics));
        _table = StateObject(wrappedValue: Table(settings: settings,
                                                 gameCenterSender: GameCenter.HttpTransport.instance));
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(self.table)
                .environmentObject(self.settings)
                .environmentObject(self.feedback)
                .task {
                    await GameCenterAuthentication.authenticate();
                    GameCenter.HttpTransport.instance.configure(handler: self.table);
                }
        }
    }
}
