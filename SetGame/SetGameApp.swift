import SwiftUI

public let  aid: String = String(ID(size: 2).value);
public func deb(_ message: String) { NSLog("XDEBUG-\(aid)> " + message) }

@main
struct SetGameApp: App {

    @StateObject private var settings: Settings = Settings();
    @StateObject private var feedback: Feedback;
    @StateObject private var table: Table;
    var session: GameCenter.Session?;

    init() {
        let settings: Settings = Settings();
        _settings = StateObject(wrappedValue: settings);
        _feedback = StateObject(wrappedValue: Feedback(sounds: settings.sounds,
                                                       haptics: settings.haptics));
        _table = StateObject(wrappedValue: Table(settings: settings));
        self.session = GameCenter.HttpSession(transport: GameCenter.HttpTransport());
    }

    var body: some Scene {
        WindowGroup {
            ContentView(session: self.session)
                .environmentObject(self.table)
                .environmentObject(self.settings)
                .environmentObject(self.feedback)
                .task {
                    await GameCenterAuthentication.authenticate();
                    if let session = self.session {
                        if await session.setup() {
                            session.bind(to: self.table);
                            deb("SetGameApp.task: call session.start")
                            session.start();
                            // self.table.startNewGame();
                        }
                    }
                }
        }
    }

    func createMultiPlayerSession() -> GameCenter.Session {
        let session: GameCenter.Session = GameCenter.HttpSession(transport: GameCenter.HttpTransport());
        return session;
    }
}
