import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var table : Table;
    @EnvironmentObject var settings : Settings;
    @EnvironmentObject var feedback : Feedback;
    @State private var showSettingsView = false;
//    @State private var feedback: Feedback = Feedback(sounds: Defaults.sounds,
 //                                                    haptics: Defaults.haptics)


var body: some View {
    NavigationView {
        ZStack {
            TableView()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("SET Game")
                            .font(.title).fontWeight(.bold)
                            .padding(.top, 6)
                            .padding(.bottom, 2)
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button { self.table.startNewGame(); feedback.trigger(); } label: {
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
                .onChange(of: settings.version) { _ in
                    Task { @MainActor in
                        await table.demoCheck()
                    }
                    feedback.soundsEnabled = settings.sounds;
                    feedback.hapticsEnabled = settings.haptics;
                }
                .onChange(of: table.settings.demoMode) { _ in
                    Task { @MainActor in
                        await table.demoCheck()
                    }
                }
            NavigationLink(destination: SettingsView()
                            .environmentObject(table)
                            .environmentObject(settings),
                           isActive: $showSettingsView) {
                EmptyView()
            }.hidden()
        }
    }.padding(.top, 4)
}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Table(displayCardCount: 12))
            .environmentObject(Settings())
    }
}
