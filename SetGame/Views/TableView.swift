import SwiftUI

struct TableView: View {

    @EnvironmentObject var table : Table;

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                let nrows = Int(ceil(Float(table.cards.count) / Float(table.settings.cardsPerRow)));
                ForEach (0..<nrows, id: \.self) { row in
                    HStack {
                        ForEach(0..<table.settings.cardsPerRow, id: \.self) { column in
                            let index = row * table.settings.cardsPerRow + column;
                            if (index < table.cards.count) {
                                CardView(card: table.cards[index]) {
                                    self.table.cardTouched($0)
                                }.slightlyRotated(self.table.settings.cardsAskew)
                            }
                            else {
                                Image("dummy").resizable()
                            }
                        }
                    }
                }
                Divider()
                StatusBarView()
                Divider()
                if (self.table.settings.showFoundSets) {
                    FoundSetsView(setsLastFound: table.state.setsLastFound,
                                  cardsAskew: table.settings.cardsAskew)
                }
            }.padding()
        }.allowsHitTesting(!self.table.state.blinking && !self.table.settings.demoMode)
    }

    // N.B. ChatGPT helped here.
    //
    public static func blinkCards(_ cards: [TableCard], times: Int = 3, interval: Double = 0.15,
                                    completion: @escaping () -> Void = {}) {

        for card in cards {
            if card.blinking {
                return;
            }
        }

        guard times > 0 else {
            completion();
            return
        }

        func setBlinking(_ on: Bool) { for card in cards { card.blink = on; card.blinking = on; } }
        func toggleBlink()           { for card in cards { card.blink = !card.blink; } }

        var togglesRemaining = times * 2; // times two because counting on/off

        setBlinking(true);
        func tick() {
            togglesRemaining -= 1;
            if (togglesRemaining <= 0) {
                setBlinking(false);
                completion();
                return;
            }
            toggleBlink();
            DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                tick();
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            tick();
        }
    }
}

/*
struct TableView_Previews: PreviewProvider {
    static var previews: some View {
        TableView()
            .environmentObject(Table(displayCardCount: 12, plantSet: true))
    }
}
*/
