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
                    //
                    // This is key:
                    // The Transport has a MessageHandler (transport.handler), which points at Table,
                    // which isa (i.e. implements) MessageHandler; and Table has MessageSender (sender)
                    // which points back to the Transport, which is also a (i.e. implements) MessageSender.
                    //
                    GameCenter.HttpTransport.instance.handler = self.table;
                    //
                    // TODO for New_ stuff ...
                    ///
                    var transport: GameCenter.HttpTransport_New = GameCenter.HttpTransport_New();
                    transport.handler = self.table;
                    self.table.sender = transport;
                    transport.bind(to: self.table);
                }
        }
    }
}
