import SwiftUI

public struct CardUI : View {
    
    @ObservedObject var card: TableCard;
                    var selectable: Bool                        = false;
                    var materialize: Bool                       = false;
                    var askew: Bool                             = false;
                    var alternate: Int?                         = nil;
                    var touchedCallback: ((TableCard) -> Void)? = nil;

    @State private var materializing: Bool;
    @State private var shakeToken: CGFloat;

    private var uid: ID = ID(short: true);

    let materializeDelay: Double = 0.4;

    init(_ card: TableCard,
           selectable: Bool = false,
           materialize: Bool = false,
           askew: Bool = false,
           alternate: Int? = nil,
         _ touchedCallback: ((TableCard) -> Void)? = nil) {

        print("CARDUI-INIT> uid: \(self.uid) card: \(card.uid) \(card.sid) \(card.vid) \(card.id) \(card.codename)")
        self.card = card;
        self.selectable = selectable;
        self.materialize = materialize;
        self.askew = askew;
        self.alternate = alternate;
        self.touchedCallback = touchedCallback;

        self._materializing = State(initialValue: materialize)
        self.shakeToken = 0;

        if (materialize) {
            card.materialize(once: true);
        }
    }

    public var body: some View {
        VStack {
            Button(action: {
                if (selectable) {
                    card.selected.toggle();
                }
                touchedCallback?(card)
            }) {
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
                    .scaleEffect(self.materializing ? 0.05 : 1.0, anchor: .center)
                    //
                    // Placing this opacity qualifier here (rather than higher up above) ensures
                    // that the entire card - including it selection border if present - blinks.
                    //
                    .opacity(self.materializing || card.blinkoff ? 0.0 : 1.0)
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
                        .spring(response: card.materializeSpeed, dampingFraction: card.materializeElasticity),
                         value: self.materializing
                    )
            }
            .skew(askew)
            // Text("\(self.uid)/\(card.vid):\(card.materializing ? "CM": "cm"):\(self.materializing ? "SM": "sm"):\(self.materialized ? "SD": "sd")").font(.system(size: 11))
        }
        .onChange(of: card.materializeTrigger) { value in
            print("CARDUI-ONCHANGE-MATERIALIZE-NONCE> card: \(card.vid) \(card.codename) value: \(value) card.materializeTrigger: \(card.materializeTrigger)")
            // if (value) ...
                self.materializing = true;
                DispatchQueue.main.asyncAfter(deadline: .now() + self.materializeDelay) {
                    print("CARDUI-ONCHANGE-MATERIALIZE-NONCE-DISPATCH> card: \(card.vid) \(card.codename) card.materializeTrigger: \(card.materializeTrigger)")
                    self.materializing = false;
                    // card.materializing = false;
                    print("CARDUI-ONCHANGE-MATERIALIZE-NONCE-DISPATCH-END> card: \(card.vid) \(card.codename) card.materializeTrigger: \(card.materializeTrigger)")
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
    
    /*
    private func doMaterialize() {
        print("CARDUI-MATERIALIZE-NONCE> card: \(card.vid) \(card.codename) card.materializeTrigger: \(card.materializeTrigger)")
        self.materializing = true;
        DispatchQueue.main.asyncAfter(deadline: .now() + self.materializeDelay) {
            print("CARDUI-MATERIALIZE-NONCE-DISPATCH> card: \(card.vid) \(card.codename) card.materializeTrigger: \(card.materializeTrigger)")
            self.materializing = false;
            print("CARDUI-MATERIALIZE-NONCE-DISPATCH-END> card: \(card.vid) \(card.codename) card.materializeTrigger: \(card.materializeTrigger)")
        }
    }
    */

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
