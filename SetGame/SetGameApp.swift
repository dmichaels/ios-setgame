import SwiftUI

public let  aid: String = String(ID(size: 2).value);
public func deb(_ message: String) { NSLog("XDEBUG-\(aid)> " + message) }

@main
struct SetGameApp: App {

    // @StateObject private var settings = Settings();
    // @StateObject private var table = Table(settings: Settings());
    // @StateObject private var feedback = Feedback(sounds: Settings().sounds, haptics: Settings().haptics);


    @StateObject private var settings: Settings
    @StateObject private var table: Table
    @StateObject private var feedback: Feedback

    public init() {
        deb("SetGameApp.init!!!")

        // 1. Construct pure objects first (locals)

        let settings = Settings()
        let table = Table(settings: settings)
        let feedback = Feedback(
            sounds: settings.sounds,
            haptics: settings.haptics
        )

        // 2. Assign to StateObject backing storage

        _settings = StateObject(wrappedValue: settings)
        _table = StateObject(wrappedValue: table)
        _feedback = StateObject(wrappedValue: feedback)

        // 3. Now safely construct HttpSession

        MultiPlayer.HttpSession.instance(
            handler: table,
            transport: { handler in
                MultiPlayer.HttpTransport(
                    handler: handler,
                    url: settings.multiPlayer.server,
                    key: settings.multiPlayer.apikey
                )
            }
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(table)
                .environmentObject(settings)
                .environmentObject(feedback)
        }
    }
}
