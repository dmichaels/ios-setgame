import SwiftUI

struct TableView: View {

    @EnvironmentObject var table : Table;
    @EnvironmentObject var settings : Settings;
    @EnvironmentObject var feedback : Feedback;

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
                                    self.table.cardTouched($0);
                                    self.feedback.trigger();
                                }
                                .slightlyRotated(self.table.settings.cardsAskew)
                                .allowsHitTesting(!self.table.state.blinking && !self.table.settings.demoMode)
                            }
                            else {
                                Image("dummy").resizable()
                            }
                        }
                    }
                }
                VStack {
                    // Rectangle().fill(Color.gray.opacity(0.8)).frame(height: 2)
                    Spacer()
                    Spacer()
                    StatusBarView()
                    Spacer()
                    // Rectangle().fill(Color.gray.opacity(0.8)).frame(height: 1)
                    if (self.table.settings.showFoundSets) {
                        FoundSetsView(setsLastFound: table.state.setsLastFound,
                                      cardsAskew: table.settings.cardsAskew)
                    }
                }.offset(y: 4)
            }.padding().offset(y: -6)
        } // .allowsHitTesting(!self.table.state.blinking && !self.table.settings.demoMode)
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
