import SwiftUI

struct TableView: View {

    @EnvironmentObject var table : Table;
    @EnvironmentObject var settings : Settings;
    @EnvironmentObject var feedback : Feedback;

    let statusResetToken: Int;

    @State private var gcStatus: String = "—"
    @State private var lastMessage: String = "—"
    // @ObservedObject private var gc = GameCenterManager.shared
    @StateObject private var gc = GameCenterManager.shared

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
                                    self.table.cardTouched($0, delay: 0.70) { cards, set, resolve in
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
                }
                /*
            GameCenterButtonsView(
                gc: gc,
                onPlayWithFriends: {
                    // you likely call your “invite friends” / matchmaking UI here
                    print("Play with Friends tapped")
                    GameCenterManager.shared.startMatchmaking(minPlayers: 2, maxPlayers: 4)
                },
                onSignIn: {
                    // re-trigger auth flow
                    // GameCenterManager.shared.authenticatePlayer()
                    print("CALL SIGNIN")
                    GameCenterManager.shared.signIn()
                }
            )
            */
            GameCenterButtonsView(gc: gc)
            }.padding().offset(y: -12)
        .onAppear {
            gc.refreshAuthState(tag: "onAppear")
        }
        }
    }

    public static func blinkCards(_ cards: [TableCard], times: Int = 3, interval: Double = 0.18,
                                    completion: @escaping () -> Void = {}) {

        // The interval is the time between blinks;
        // the lower the faster the blink.

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
struct GameCenterButtonsView: View {
    @ObservedObject var gc: GameCenterManager

    var body: some View {
        VStack(spacing: 10) {
            Button("Sign In to Game Center") {
                gc.signInUserInitiated()
            }
            .buttonStyle(.borderedProminent)
            .disabled(gc.isAuthenticated)

            HStack {
                Text(gc.isAuthenticated ? "Signed in as:" : "Not signed in")
                Spacer()
                Text(gc.displayName).lineLimit(1)
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .alert("Game Center Sign-In", isPresented: $gc.showOpenSettingsAlert) {
            Button("Open Settings") { gc.openSettings() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("iOS didn’t present the Game Center sign-in dialog. Please sign in in Settings ▸ Game Center, then return to the app.\n\nLast error: \(gc.lastAuthError)")
        }
        .padding(.horizontal)
    }
}
