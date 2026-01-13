import SwiftUI

public struct CardUI : View {
    
    @ObservedObject var card: TableCard;
                    var materialize: Bool                       = false;
                    var askew: Bool                             = false;
                    var alternate: Int?                         = nil;
                    var touchedCallback: ((TableCard) -> Void)? = nil;

    @State private var materializing: Bool;
    @State private var materialized: Bool;
    @State private var shakeToken: CGFloat;

    let materializeDelay: Double = 0.5;
    let materializeSpeed: Double = 0.7;
    let materializeElasticity: Double = 0.4;

    init(_ card: TableCard,
           materialize: Bool = false,
           askew: Bool = false,
           alternate: Int? = nil,
         _ touchedCallback: ((TableCard) -> Void)? = nil) {

        self.card = card;
        self.materialize = materialize;
        self.askew = askew;
        self.alternate = alternate;
        self.touchedCallback = touchedCallback;

        self.materializing = materialize;
        self.materialized = false;
        self.shakeToken = 0;
    }

    init(_ card: String,
           materialize: Bool = false,
           askew: Bool = false,
           alternate: Int? = nil,
         _ touchedCallback: ((TableCard) -> Void)? = nil) {
        self.init(TableCard(card) ?? TableCard("DUMMY")!,
                  materialize: materialize,
                  askew: askew,
                  alternate: alternate,
                  touchedCallback);
    }

    public var body: some View {
        VStack {
            Button(action: { touchedCallback?(card) }) {
                Image(self.image(card, alternate))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: card.selected ? 10 : 6)
                            .stroke(card.selected ? Color.red : Color.gray, lineWidth: card.selected ? 3 : 1)
                    )
                    .shadow(color: card.selected ? Color.green : Color.green, radius: card.selected ? 4 : 1)
                    .padding(1)
                    //
                    // These two qualifiers are needed to shake
                    // the cards; e.g. on an incorrect SET guess.
                    //
                    .modifier(
                        ShakeEffect(shakesPerUnit: CGFloat(card.shakeCount),
                                    animatableData: card.shaking ? CGFloat(shakeToken) : 0)
                    )
                    .onChange(of: card.shaking) { value in
                        if (value) {
                            print("on-change-shaking> count: \(card.shakeCount) speed: \(card.shakeSpeed)")
                            var t = Transaction();
                            t.animation = .linear(duration: card.shakeSpeed);
                            withTransaction(t) {
                                self.shakeToken += 1;
                            }
                            card.shaking = false;
                        }
                    }
                    //
                    // This is the twirling effect when selecting or unselected a card.
                    //
                    .rotation3DEffect(
                        card.selected ? Angle(degrees: 360) : Angle(degrees: 0),
                        axis: (x: CGFloat(card.selected ? 0 : 1),
                               y: CGFloat(card.selected ? 0 : 1),
                               z: CGFloat(card.selected ? 1 : 0))
                    )
                    //
                    // This controls the card animation for selecting, i.e. twirling the card around,
                    // per the above rotation; the duration here controls how long that twirling takes;
                    // and note that this is not done while blinking.
                    //
                    .animation(card.blinking ? nil : .linear(duration: 0.20), value: card.selected)
                    .animation(nil, value: card.blinkoff)
                    //
                    // Optional: Also ensure blinkoff toggles don’t animate (belt+suspenders).
                    //
                    .scaleEffect(materializing ? 0.05 : 1.0, anchor: .center)
                    //
                    // Placing this opacity qualifier here (rather than higher up above) ensures
                    // that the entire card - including it selection border if present - blinks.
                    //
                    .opacity(materializing || card.blinkoff ? 0.0 : 1.0)
                    //
                    // Animation for newly added "materialized" cards.
                    // - The response argument to the .spring qualifier
                    //   qualifier controls how fast the spring is;
                    //   lower is faster; higher is slower.
                    // - The dampingFraction argument to .spring qualifier
                    //   qualifier controls how flexible/slopping the bounce is;
                    //   lower is bouncier and sloppier; higher is stiffer.
                    //
                    // .animation(.spring(response: 0.70, dampingFraction: 0.40), value: materializing)
                    .animation(
                        .spring(response: self.materializeSpeed, dampingFraction: self.materializeElasticity),
                         value: materializing
                    )
            }
            .skew(askew)
            .onAppear {
                print("card-ui-on-appear> materializing: \(materializing) materialized: \(materialized)")
                if (materializing && !materialized) {
                    self.materializing = true;
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.materializeDelay) {
                        self.materializing = false;
                        self.materialized = true;
                    }
                }
            }
        }
        .onChange(of: card.materializing) { value in
            if (value) {
                self.materializing = true;
                DispatchQueue.main.asyncAfter(deadline: .now() + self.materializeDelay) {
                    self.materializing = false;
                    card.materializing = false;
                }
            }
        }
        .onChange(of: card.blinking) { value in
            if (value) {
                var nblinks: Int = card.blinkCount;
                var niterations: Int = nblinks * 2;
                func blink() {
                    niterations -= 1 ; if (niterations <= 0) {
                        card.blinkoff = false;
                        card.blinking = false;
                        if let blinkDoneCallback = card.blinkDoneCallback {
                            DispatchQueue.main.async {
                                blinkDoneCallback();
                            }
                        }
                        return;
                    }
                    if (card.blinkoff) {
                        card.blinkoff = false;
                        DispatchQueue.main.asyncAfter(deadline: .now() + card.blinkInterval) {
                            blink();
                        }
                    }
                    else {
                        card.blinkoff = true;
                        DispatchQueue.main.asyncAfter(deadline: .now() + card.blinkoffInterval) {
                            blink();
                        }
                    }
                }
                blink();

            }
        }
    }
    

    private func image(_ card: TableCard, _ alternate: Int? = nil) -> String {
        //
        // The default cards are the classic SET Game ones.
        // - Original ones from Java based SET Game circa 1999.
        // The ALTD_ cards are the rectangle color based ones.
        // - See ios-setgame/etc/alternate_cards/alternate_cards_analogous.py
        // The ALTNC_ cards are the monochrome (no-color) based ones.
        // - See ios-setgame/etc/alternate_cards/alternate_cards_no_colors.py
        //
        switch alternate ?? 0 {
            case 0:  return card.codename;
            case 1:  return "ALTD_\(card.codename)";
            case 2:  return "ALTNC_\(card.codename)";
            default: return card.codename;
        }
    }
}

private struct ShakeEffect: GeometryEffect {
    var angle: CGFloat = 8.0
    var shakesPerUnit: CGFloat = 9.0
    var animatableData: CGFloat
    func effectValue(size: CGSize) -> ProjectionTransform {
        let a = angle * sin(animatableData * .pi * 2 * shakesPerUnit)
        let t = CGAffineTransform(translationX: size.width/2, y: size.height/2)
            .rotated(by: a * (.pi / 180))
            .translatedBy(x: -size.width/2, y: -size.height/2)
        return ProjectionTransform(t)
    }
}

private struct SlightRandomRotation: ViewModifier {
    @State private var angle: Double = Double(Int.random(in: -2...2))
    public func body(content: Content) -> some View {
        content.rotationEffect(.degrees(angle));
    }
}

extension View {
    fileprivate func skew(_ enabled: Bool = true) -> some View {
        Group { if enabled { self.modifier(SlightRandomRotation()) } else { self } }
    }
}
