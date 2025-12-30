import SwiftUI

/*
@main
struct SetGameApp: App {
    let xsettings = XSettings();
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(Table(displayCardCount: Defaults.displayCardCount, plantSet: Defaults.plantSet, xsettings: xsettings))
                .environmentObject(Settings())
                .environmentObject(xsettings)
                .environmentObject(Feedback(sounds: Defaults.sounds, haptics: Defaults.haptics))
        }
    }
}
*/

@main
struct SetGameApp: App {

    @StateObject private var xsettings: XSettings = XSettings();
    // @StateObject private var settings: Settings = Settings();
    @StateObject private var feedback: Feedback;
    @StateObject private var table: Table<TableCard>;

    init() {
        let shared_xsettings: XSettings = XSettings()
        // let shared_settings: Settings = Settings();
        _xsettings = StateObject(wrappedValue: shared_xsettings);
        // _settings  = StateObject(wrappedValue: shared_settings);
        _feedback  = StateObject(wrappedValue: Feedback(sounds: Defaults.sounds, haptics: Defaults.haptics));
        _table     = StateObject(wrappedValue: Table(xsettings: shared_xsettings));
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(self.table)
                // .environmentObject(self.settings)
                .environmentObject(self.xsettings)
                .environmentObject(self.feedback)
        }
    }
}
