import SwiftUI

// This was previously TableView by factored out into this TableUI module
// to eliminate references to global environment (@EnvironmentObject)
// state, in order to facilitate multi-player (GameCenter) functionality.
//
struct TableUI: View {

    @ObservedObject var table : Table<TableCard>;
    @ObservedObject var settings : Settings;
    @ObservedObject var feedback : Feedback;

    @ObservedObject private var gameCenter = GameCenterManager.shared;

    let statusResetToken: Int;

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
                                    //
                                    // Note that this delay here on cardTouched is the  amount
                                    // of time that the cards will remain visually highlighted
                                    // when 3 cards are selected, before they either blink, because
                                    // they form a SET; or before they shake, because they do not.
                                    //
                                    self.table.cardTouched($0, delay: 0.75) { cards, set, resolve in
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
                                                TableCardEffects.blinkCards(cards, times: 5) {
                                                    self.feedback.trigger(Feedback.SET);
                                                    resolve();
                                                }
                                            }
                                            else {
                                                self.feedback.trigger(Feedback.NOSET, Feedback.HAPTIC_NOSET);
                                                resolve();
                                            }
                                        }
                                        else {
                                            self.feedback.trigger(Feedback.TAP, Feedback.HAPTIC_TAP);
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
                    StatusBarView(resetToken: statusResetToken)
                    Spacer(minLength: 20)
                    if (self.settings.showFoundSets) {
                        FoundSetsView(setsLastFound: table.state.setsLastFound,
                                      cardsAskew: settings.cardsAskew)
                    }
                    PlayButtonView(gameCenter: gameCenter)
                        .padding(.horizontal)
                }
            }.padding().offset(y: -12)
        }
    }
}
