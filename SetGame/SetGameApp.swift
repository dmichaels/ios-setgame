import SwiftUI

public let  aid: String = String(ID(size: 2).value);
public func deb(_ message: String) { NSLog("XDEBUG-\(aid)> " + message) }

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
        _table = StateObject(wrappedValue: Table(settings: settings));

        MultiPlayer.HttpSession.instance(handler: self.table, transport: {
            handler in
            MultiPlayer.HttpTransport(handler: handler,
                                      url: settings.multiPlayer.server,
                                      key: settings.multiPlayer.apikey)
        });
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(self.table)
                .environmentObject(self.settings)
                .environmentObject(self.feedback)
                .task {
                    await GameCenterAuthentication.authenticate();
                    GameCenter.HttpSession.create(handler: self.table);
/*
                    if let session: GameCenter.Session = await GameCenter.HttpSession.create(handler: self.table) {
                        session.start();
                    }
*/
                }
        }
    }
}
