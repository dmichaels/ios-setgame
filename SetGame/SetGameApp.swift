import SwiftUI

public let  aid: String = String(ID(size: 3).value);
public func deb(_ message: String) { NSLog("XDEBUG-\(aid)> " + message) }

@main
struct SetGameApp: App {

    @StateObject private var settings: Settings
    @StateObject private var table: Table
    @StateObject private var feedback: Feedback

    public init() {

        let settings: Settings = Settings();
        let table: Table = Table(settings: settings);
        let feedback: Feedback = Feedback(sounds: settings.sounds, haptics: settings.haptics);

        _settings = StateObject(wrappedValue: settings);
        _table = StateObject(wrappedValue: table);
        _feedback = StateObject(wrappedValue: feedback);

        // This MUST be called EXACTLY ONCE at startup; BEFORE the
        // HttpSession.instance property is referenced elsewehere.
        // And note that this construction is, by design, inert;
        // meaning it does not access the network or do anything
        // substantial beyond hooking up internal state/properties.
        //
        MultiPlayer.HttpSession.instance(
            handler: table,
            transport: { handler in
                MultiPlayer.HttpTransport(
                    handler: handler,
                    url: settings.multiPlayer.urlProduction,
                    urlDevelopment: settings.multiPlayer.urlDevelopment,
                    key: settings.multiPlayer.apikey
                )
            }
        );
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
