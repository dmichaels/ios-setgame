import SwiftUI

struct ContentView: View {

    @EnvironmentObject var table : Table;
    @EnvironmentObject var settings : Settings;
    @EnvironmentObject var feedback : Feedback;

    @State private var showSettingsView = false;

    @State private var saveMoveSetFront: Bool = false;
    @State private var saveSimpleDeck: Bool = false;

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
                        Task { /* @MainActor in - dont need this anymore somehow? */
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
        self.saveMoveSetFront = self.settings.moveSetFront;
        self.saveSimpleDeck = self.settings.simpleDeck;
    }

    private func onBackFromSettingsView() {
        if ((self.settings.simpleDeck != self.saveSimpleDeck) &&
            (self.table.gameStart() || self.table.gameDone())) {
            self.table.startNewGame();
        }
        else {
            if (self.settings.moveSetFront && !self.saveMoveSetFront) {
                self.table.moveAnyExistingSetToFront();
            }
        }
        self.feedback.sounds = settings.sounds;
        self.feedback.haptics = settings.haptics;
    }
}
