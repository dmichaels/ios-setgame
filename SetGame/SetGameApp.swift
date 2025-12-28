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
    @StateObject private var settings: Settings = Settings();
    @StateObject private var feedback: Feedback;
    @StateObject private var table: Table<TableCard>;

    init() {
        let sharedXSettings: XSettings = XSettings()
        let sharedSettings: Settings = Settings();
        _settings = StateObject(wrappedValue: sharedSettings);
        _feedback = StateObject(wrappedValue: Feedback(sounds: Defaults.sounds, haptics: Defaults.haptics));
        _table = StateObject(wrappedValue: Table(displayCardCount: Defaults.displayCardCount,
                                                 plantSet: Defaults.plantSet, xsettings: sharedXSettings));
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(self.table)
                .environmentObject(self.settings)
                .environmentObject(self.feedback)
        }
    }
}
