import SwiftUI

@main
struct SetGameApp: App {

    @StateObject private var settings: Settings = Settings();
    @StateObject private var feedback: Feedback;
    @StateObject private var table: Table;

    init() {
///xyzzy
        var c: [Card] = [Card("ROH1")!, Card("GDT2")!]
        var m: GameCenter.DealCardsMessage = GameCenter.DealCardsMessage(player: "A", cards: c);
        if let d: Data = m.serialize() {
            if let r: GameCenter.DealCardsMessage = GameCenter.DealCardsMessage(d) {
                print("OK")
            }
        }
        var cc: [Card] = [Card("ROH1")!, Card("GDT2")!]
        var mm: GameCenter.DealCardsMessage = GameCenter.DealCardsMessage(player: "A", cards: cc);
        print("\(m.type == mm.type)")
        print("\(m.player == mm.player)")
        print("\(m.cards == mm.cards)")
        print("\(mm.cards)")
///xyzzy
        let shared_settings: Settings = Settings();
        _settings = StateObject(wrappedValue: shared_settings);
        _feedback = StateObject(wrappedValue: Feedback(sounds: shared_settings.sounds,
                                                       haptics: shared_settings.haptics));
        _table = StateObject(wrappedValue: Table(settings: shared_settings));
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(self.table)
                .environmentObject(self.settings)
                .environmentObject(self.feedback)
                // .task {
                //     await GameCenterAuthentication.authenticate()
                // }
        }
    }
}
