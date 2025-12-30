import SwiftUI

struct ContentView: View {

    @EnvironmentObject var table : Table;
    // @EnvironmentObject var settings : Settings;
    @EnvironmentObject var xsettings : XSettings;
    @EnvironmentObject var feedback : Feedback;

    @State private var showSettingsView = false;

    let title: String = "Logicard";

    class SaveSettings {
        public var moveSetFront: Bool = Defaults.moveSetFront;
        public var sounds: Bool = Defaults.sounds;
        public var haptics: Bool = Defaults.haptics;
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
                            Text(self.xsettings.demoMode ? "\(title) Demo →" : title)
                                .font(.system(size: 28))
                                .fontWeight(.bold)
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Menu {
                                Button { self.table.startNewGame(); feedback.trigger(Feedback.BADING); } label: {
                                    Label("New Game" , systemImage: "arrow.counterclockwise")
                                }.disabled(self.table.state.blinking || self.xsettings.demoMode)
                                Button { self.table.addMoreCards(1) } label: {
                                    Label("Add Card" , systemImage: "plus.rectangle")
                                }.disabled(self.table.state.blinking || self.xsettings.demoMode)
                                Toggle(isOn: $xsettings.demoMode) {
                                    Label("Demo Mode", systemImage: "play.circle")
                                }
                                Button { self.showSettingsView = true } label: {
                                    Label("Settings ...", systemImage: "gearshape")
                                }.disabled(self.table.state.blinking || self.xsettings.demoMode)
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
                            self.saveSettings.moveSetFront = self.xsettings.moveSetFront;
                            self.saveSettings.sounds = self.xsettings.sounds;
                            self.saveSettings.haptics = self.xsettings.haptics;
                        }
                        else {
                            //
                            // Back from SettingsView.
                            //
                            print("BACK-FROM-SETTINGS")
                            if ((self.xsettings.simpleDeck != self.saveSettings.simpleDeck) &&
                                (self.table.gameStart() || self.table.gameDone())) {
                                self.table.startNewGame();
                            }
                            else {
                                if (self.xsettings.moveSetFront && !self.saveSettings.moveSetFront) {
                                    self.table.moveAnyExistingSetToFront();
                                }
                            }
                        }
                    }
                    .onChange(of: xsettings.demoMode) { _ in
                        Task { @MainActor in
                            await table.demoCheck()
                        }
                    }
                NavigationLink(destination:
                    SettingsView().environmentObject(table)
                                  .environmentObject(xsettings), isActive: $showSettingsView) {
                                  // .environmentObject(settings), isActive: $showSettingsView) CURLY
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
