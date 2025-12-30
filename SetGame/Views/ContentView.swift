import SwiftUI

struct ContentView: View {

    @EnvironmentObject var table : Table;
    @EnvironmentObject var settings : Settings;
    @EnvironmentObject var xsettings : XSettings;
    @EnvironmentObject var feedback : Feedback;

    @State private var showSettingsView = false;

    let title: String = "Logicard";

    class SaveSettings {
        public var moveSetFront: Bool = Defaults.moveSetFront;
        public var haptics: Bool = Defaults.haptics;
        public var sounds: Bool = Defaults.sounds;
    }

    // @State var saveSettings: SaveSettings = SaveSettings();
    @State var saveSettings: XSettings = XSettings();

    var body: some View {
        NavigationView {
            ZStack {
                TableView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text(self.table.settings.demoMode ? "\(title) Demo →" : title)
                                .font(.system(size: 28))
                                .fontWeight(.bold)
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Menu {
                                Button { self.table.startNewGame(); feedback.trigger(Feedback.BADING); } label: {
                                    Label("New Game" , systemImage: "arrow.counterclockwise")
                                }.disabled(self.table.state.blinking || self.table.settings.demoMode)
                                Button { self.table.addMoreCards(1) } label: {
                                    Label("Add Card" , systemImage: "plus.rectangle")
                                }.disabled(self.table.state.blinking || self.table.settings.demoMode)
                                Toggle(isOn: $table.settings.demoMode) {
                                    Label("Demo Mode", systemImage: "play.circle")
                                }
                                Button { self.showSettingsView = true } label: {
                                    Label("Settings ...", systemImage: "gearshape")
                                }.disabled(self.table.state.blinking || self.table.settings.demoMode)
                            } label: {
                                Image(systemName: "gearshape.fill")
                                    .foregroundColor(Color(UIColor.darkGray))
                            }
                        }
                    }
                    .onChange(of: self.showSettingsView) { _ in
                        if (self.showSettingsView) {
                            //
                            // Going to SettingsView.
                            //
                            self.saveSettings.moveSetFront = self.xsettings.moveSetFront
                        }
                        else {
                            //
                            // Back from SettingsView.
                            //
                            if (self.xsettings.moveSetFront && !self.saveSettings.moveSetFront) {
                                self.table.moveAnyExistingSetToFront();
                            }
                        }
                    }
                    .onChange(of: xsettings.version) { _ in
                        // print("ContentView> onChange(xsettings.version) | show: (\(showSettingsView)) | xsettings.version: \(self.xsettings.version)")
                    }
                    .onChange(of: settings.version) { _ in
                        Task { @MainActor in
                            await table.demoCheck()
                        }
                        feedback.sounds = settings.sounds;
                        feedback.haptics = settings.haptics;
                    }
                    .onChange(of: table.settings.demoMode) { _ in
                        Task { @MainActor in
                            await table.demoCheck()
                        }
                    }
                    .onChange(of: table.settings.simpleDeck) { _ in
                        if (self.table.gameStart() || self.table.gameDone()) {
                            self.table.startNewGame();
                        }
                    }
                    .onChange(of: xsettings.moveSetFront) { _ in
                        print("MOVE_SET_FRONT")
                    }
                NavigationLink(destination:
                    SettingsView().environmentObject(table)
                                  .environmentObject(xsettings)
                                  .environmentObject(settings), isActive: $showSettingsView) {
                        EmptyView()
                    }.hidden()
            }
        }
        //
        // This line is necessary to make the app
        // look normal and not split screen on iPad.
        //
        .navigationViewStyle(.stack)
    }
}
