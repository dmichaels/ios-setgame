import SwiftUI

struct TableView: View {

    @EnvironmentObject var table : Table;
    @EnvironmentObject var settings : Settings;
    @EnvironmentObject var feedback : Feedback;

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                let nrows = Int(ceil(Float(table.cards.count) / Float(settings.cardsPerRow)));
                ForEach (0..<nrows, id: \.self) { row in
                    HStack {
                        /*
                        ForEach(table.cards) { card in
                            CardView(card: card, touchedCallback: { /* ... */ })
                                .transition(.popInCard)
                        }
                        .animation(.spring(response: 0.22, dampingFraction: 0.85), value: table.cards.map(\.id))
                        */
                        ForEach(0..<settings.cardsPerRow, id: \.self) { column in
                            let index = row * settings.cardsPerRow + column;
                            if (index < table.cards.count) {
                                CardView(card: table.cards[index]) {
                                    self.table.cardTouched($0) { result in
                                        if (result == nil) {
                                            self.feedback.trigger(Feedback.TAP);
                                        }
                                        else if (result == false) {
                                            self.feedback.trigger(Feedback.CANCEL);
                                        }
                                        else if (result == true) {
                                            self.feedback.trigger(Feedback.SWOOSH);
                                        }
                                    }
                                }
                                .slightlyRotated(self.settings.cardsAskew)
                                .allowsHitTesting(!self.table.state.disabled && !self.settings.demoMode)
                            }
                            else {
                                Color.clear
                            }
                        }
                    }
                }
                VStack {
                    Spacer(minLength: 24)
                    StatusBarView()
                    Spacer(minLength: 20)
                    if (self.settings.showFoundSets) {
                        FoundSetsView(setsLastFound: table.state.setsLastFound,
                                      cardsAskew: settings.cardsAskew)
                    }
                }
            }.padding().offset(y: -12)
        }
    }

    public static func blinkCards(_ cards: [TableCard], times: Int = 3, interval: Double = 0.15,
                                    completion: @escaping () -> Void = {}) {

        guard !cards.blinking else {
            return;
        }

        guard times > 0 else {
            completion();
            return;
        }

        var nblinks = times * 2; // times two because counting on/off

        cards.blinkingStart();

        func tick() {
            nblinks -= 1 ; if (nblinks <= 0) {
                cards.blinkingEnd();
                completion();
                return;
            }
            cards.blinkoutToggle();
            DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                tick();
            }
        }

        tick();
    }
}
