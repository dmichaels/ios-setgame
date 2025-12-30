import SwiftUI

struct ContentView: View {

    @EnvironmentObject var table : Table;
    @EnvironmentObject var settings : Settings;
    @EnvironmentObject var feedback : Feedback;

    @State private var showSettingsView = false;

    @State var saveSettings: Settings = Settings();

    var body: some View {
        NavigationView {
            ZStack {
                TableView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text(self.settings.demoMode ? "\(Defaults.title) Demo →" : Defaults.title)
                                .font(.system(size: 28))
                                .fontWeight(.bold)
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Menu {
                                Button { self.table.startNewGame(); feedback.trigger(Feedback.BADING); } label: {
                                    Label("New Game" , systemImage: "arrow.counterclockwise")
                                }.disabled(self.table.state.blinking || self.settings.demoMode)
                                Button { self.table.addMoreCards(1) } label: {
                                    Label("Add Card" , systemImage: "plus.rectangle")
                                }.disabled(self.table.state.blinking || self.settings.demoMode)
                                Toggle(isOn: $settings.demoMode) {
                                    Label("Demo Mode", systemImage: "play.circle")
                                }
                                Button { self.showSettingsView = true } label: {
                                    Label("Settings ...", systemImage: "gearshape")
                                }.disabled(self.table.state.blinking || self.settings.demoMode)
                            } label: {
                                Image(systemName: "gearshape.fill")
                                    .foregroundColor(Color(UIColor.darkGray))
                            }
                        }
                    }
                    .onChange(of: self.showSettingsView) { _ in
                        self.showSettingsView ? self.onGoToSettingsView() : onBackFromSettingsView();
                    }
                    .onChange(of: settings.demoMode) { _ in
                        Task { @MainActor in
                            await table.demoCheck()
                        }
                    }
                NavigationLink(destination:
                    SettingsView().environmentObject(table)
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

    private func onGoToSettingsView() {
        self.saveSettings.moveSetFront = self.settings.moveSetFront;
        self.saveSettings.sounds = self.settings.sounds;
        self.saveSettings.haptics = self.settings.haptics;
    }

    private func onBackFromSettingsView() {
        if ((self.settings.simpleDeck != self.saveSettings.simpleDeck) &&
            (self.table.gameStart() || self.table.gameDone())) {
            self.table.startNewGame();
        }
        else {
            if (self.settings.moveSetFront && !self.saveSettings.moveSetFront) {
                self.table.moveAnyExistingSetToFront();
            }
        }
    }
}
