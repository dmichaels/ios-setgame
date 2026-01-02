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
                        ForEach(0..<settings.cardsPerRow, id: \.self) { column in
                            let index = row * settings.cardsPerRow + column;
                            if (index < table.cards.count) {
                                CardView(card: table.cards[index]) {
                                    self.table.cardTouched($0, delay: 0.5) { cards, set, resolve in
                                        //
                                        // The given cards argument will always
                                        // be the list of cards now selected.
                                        //
                                        // The given set argument will be true if three cards are now
                                        // selected and they form a SET, or it will be false if three
                                        // cards are now selected which are not a SET; if than three
                                        // cards are now selected it will be nil.
                                        //
                                        // N.B. If this callback is specified at all to the cardTouched
                                        // function, then it is our responsibility to (we MUST) call
                                        // the given resolve function at the end of any processing.
                                        //
                                        if let set: Bool = set {
                                            if (set) {
                                                TableView.blinkCards(cards, times: 5) {
                                                    self.feedback.trigger(Feedback.SWOOSH);
                                                    resolve();
                                                }
                                            }
                                            else {
                                                self.feedback.trigger(Feedback.CANCEL);
                                                resolve();
                                            }
                                        }
                                        else {
                                            self.feedback.trigger(Feedback.TAP);
                                            resolve();
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
