import SwiftUI

public struct ContentView: View {

    @EnvironmentObject var table : Table;
    @EnvironmentObject var settings : Settings;
    @EnvironmentObject var feedback : Feedback;

    @State private var showNewGameConfirmation = false;
    @State private var showSettingsView = false;
    @State private var statusResetToken = 0;
    @State private var saveMoveSetFront: Bool = false;
    @State private var saveSimpleDeck: Bool = false;

    // let background: Color = Color(.sRGB, red: 0.93, green: 0.96, blue: 1.00, opacity: 1.0);
    // let background: Color = Color(hex: 0xEDF5FF);
    // let background: Color = Color(hex: 0xDCE4EE);
    let background: Color = Color(hex: 0xDCEEE4);

    public var body: some View {
        NavigationView {
            ZStack {
                background.ignoresSafeArea()
                TableView(statusResetToken: statusResetToken)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text(self.settings.demoMode ? "\(Defaults.title) Demo →" : Defaults.title)
                                .font(.system(size: 28))
                                .fontWeight(.bold)
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Menu {
                                Button {
                                    if ((self.table.gameStart() || self.table.gameDone())) {
                                        self.table.startNewGame();
                                        self.statusResetToken += 1;
                                        feedback.trigger(Feedback.NEW);
                                    }
                                    else {
                                        self.showNewGameConfirmation = true;
                                    }
                               } label: {
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
                        Task {
                            await table.demoCheck()
                        }
                    }
                NavigationLink(destination:
                    SettingsView().environmentObject(table)
                                  .environmentObject(settings), isActive: $showSettingsView) {
                        EmptyView()
                    }.hidden()
            }
            .alert("Start New Game?", isPresented: $showNewGameConfirmation) {
                Button("Yes", role: .destructive) {
                    self.table.startNewGame();
                    self.statusResetToken += 1;
                    feedback.trigger(Feedback.NEW);
                }
                Button("Cancel", role: .cancel) { }
            }
            //
            // Swipe-left for settings.
            //
            .simultaneousGesture(
                DragGesture(minimumDistance: 200)
                    .onEnded { value in
                        let dx: CGFloat = value.predictedEndTranslation.width;
                        if (dx < -150) {
                            let dy: CGFloat = value.predictedEndTranslation.height;
                            if (abs(dx) > (abs(dy) * 2)) {
                                showSettingsView = true;
                            }
                        }
                    }
            )
        }
        //
        // This line deals with larger system font sizes (like Kenna's).
        //
        .dynamicTypeSize(.small ... .xxLarge) // deals with larger system font sizes
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
