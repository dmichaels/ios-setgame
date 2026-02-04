import SwiftUI

public let  aid: String = String(ID(size: 2).value);
public func deb(_ message: String) { NSLog("XDEBUG-\(aid)> " + message) }

@main
struct SetGameApp: App {

    @StateObject private var settings: Settings = Settings();
    @StateObject private var feedback: Feedback;
    @StateObject private var table: Table;

    var transport: GameCenter.HttpTransport;
    var session: GameCenter.Session;

    init() {
        let settings: Settings = Settings();
        _settings = StateObject(wrappedValue: settings);
        _feedback = StateObject(wrappedValue: Feedback(sounds: settings.sounds,
                                                       haptics: settings.haptics));
        _table = StateObject(wrappedValue: Table(settings: settings,
                                                 gameCenterSender: GameCenter.HttpTransport.instance));
        self.transport = GameCenter.HttpTransport();
        self.session = GameCenter.HttpSession(transport: transport);
    }

    var body: some Scene {
        WindowGroup {
            ContentView(session: self.session)
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
                    // GameCenter.HttpTransport.instance.handler = self.table;
                    GameCenter.HttpTransport.instance.bind(to: self.table);
                    //
                    // TODO for New_ stuff ...
                    //
                    // var transport: GameCenter.HttpTransport_New = GameCenter.HttpTransport_New();
                    // transport.handler = self.table;
                    // self.table.sender = transport;
                    // transport.bind(to: self.table);
                    //
                    if (self.settings.multiPlayer.http) {
                    }
                    else {
                    }
                    // var transport: GameCenter.HttpTransport = GameCenter.HttpTransport();
                    // var session: GameCenter.Session = GameCenter.HttpSession(transport: transport);
                    if await self.session.start() {
                        self.session.bind(to: self.table);
                    }
                    let x = 1 
                }
        }
    }
}
