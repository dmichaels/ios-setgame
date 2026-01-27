import SwiftUI

@main
struct SetGameApp: App {

    @StateObject private var settings: Settings = Settings();
    @StateObject private var feedback: Feedback;
    @StateObject private var table: Table;

    init() {
        let gameCenterTransport: GameCenter.Transport? = Defaults.gameCenter ? GameCenter.HttpTransport(player: "A") : nil;
        let settings: Settings = Settings();
        _settings = StateObject(wrappedValue: settings);
        _feedback = StateObject(wrappedValue: Feedback(sounds: settings.sounds,
                                                       haptics: settings.haptics));
        _table = StateObject(wrappedValue: Table(settings: settings, gameCenterSender: gameCenterTransport));
        gameCenterTransport?.setHandler(self.table);
        foo()
    }
    func foo() {
        let cards: [TableCard] = [TableCard("ROS3")!];
        // let message: GameCenter.FoundSetMessage = GameCenter.FoundSetMessage(player: "A", cards: cards);
        let message: GameCenter.PlayerReadyMessage = GameCenter.PlayerReadyMessage(player: "A");
        if let data: Data? = message.serialize() {
            let x = GameCenter.PlayerReadyMessage(data);
            // let x = GameCenter.FoundSetMessage(data);
            print("FOFOFOFOFOFOFOFOF")
            print(x)
            print(type(of: x))
            print("end-FOFOFOFOFOFOFOFOF")
        }
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
