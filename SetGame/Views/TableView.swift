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
                                    cardTouched($0)
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
        }.allowsHitTesting(!self.table.state.blinking)
    }

    private func cardTouched(_ card : TableCard) {
        //
        // First we notify the table model that the card has been touched,
        // i.e. selected/unselected toggle, then we ask the table check to
        // check if a 3 card SET has been selected, in which case it would
        // remove the SET cards and replace them with new ones from the deck,
        // or if no SET, but 3 cards selected, then it would unselect the cards.
        //
        // Done in two steps because the CardView needs a breather to do its
        // visual flipping. This breather is manifested as a delay on the SET
        // check action. Without this delay, when the third card was selected,
        // we wouldn't see its flipping before it either got replaced by a new
        // card, if a SET; or got immediatly unselected, if no SET.
        //
        // No idea right now if this is the right/Swift-y way
        // to handle such a situation; but it does work for now.
        //
        self.table.touchCard(card);
        delayQuick() {
            let setCards: [Card] = self.table.checkForSet(readonly: true)
            if (setCards.count == 3) {
                let setTableCards: [TableCard] = setCards.compactMap { $0 as? TableCard }
                self.table.state.blinking = true;
                TableView.blinkCards(setTableCards, times: 5) {
                    self.table.checkForSet();
                    self.table.state.blinking = false;
                }
            }
        }
    }

    private func delayQuick(_ seconds : Float = 0.0, _ callback: @escaping () -> Void) {
        if (seconds < 0) {
            callback();
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                callback();
            }
        }
    }

    private func pairCardsListForDisplay(_ cardsList: [[TableCard]]) -> [[TableCard]] {
        var result: [[TableCard]] = []
        var i: Int = 0
        while (i < cardsList.count) {
            if ((i + 1) < cardsList.count) {
                result.append(cardsList[i].sorted() + cardsList[i + 1].sorted())
            } else {
                result.append(cardsList[i].sorted())
            }
            i += 2
        }
        return result
    }

    // N.B. ChatGPT helped here.
    //
    public static func blinkCards(_ cards: [TableCard], times: Int = 3, interval: Double = 0.10,
                                    completion: @escaping () -> Void = {}) {

        guard times > 0 else { completion(); return }

        func setBlinking(_ on: Bool) { for card in cards { card.blinking = on; card.blink = on; } }
        func setBlink   (_ on: Bool) { for card in cards { card.blink = on; } }
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
