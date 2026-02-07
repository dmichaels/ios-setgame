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
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(self.table)
                .environmentObject(self.settings)
                .environmentObject(self.feedback)
                .task {
                    await GameCenterAuthentication.authenticate();
                    if let session: GameCenter.Session = await createSession(handler: self.table) {
                        session.start();
                    }
                }
        }
    }

    private func createSession(handler: GameCenter.SessionHandler) async -> GameCenter.Session? {
        let session: GameCenter.Session = GameCenter.HttpSession(transport: GameCenter.HttpTransport());
        if (await session.setup()) {
            session.bind(to: handler);
            return session;
        }
        else {
            session.release();
            return nil;
        }
    }
}
