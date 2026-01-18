import SwiftUI

public struct CardView : View {
    
    @ObservedObject var card: TableCard;
                    var selectable: Bool                        = false;
                    var materialize: Bool                       = false;
                    var materializeDelay: Double?               = nil;
                    var askew: Bool                             = false;
                    var alternate: Int?                         = nil;
                    var touchedCallback: ((TableCard) -> Void)? = nil;

    private struct Defaults {
        fileprivate static let materializeDelay: Double = 0.4;
    }

    @State private var materializing: Bool;
    @State private var shakeToken: CGFloat;

    public init(_ card: TableCard,
                  selectable: Bool = false,
                  materialize: Bool = false,
                  materializeDelay: Double? = nil,
                  askew: Bool = false,
                  alternate: Int? = nil,
                _ touchedCallback: ((TableCard) -> Void)? = nil) {

        self.card = card;
        self.selectable = selectable;
        self.materialize = materialize;
        self.askew = askew;
        self.alternate = alternate;
        self.touchedCallback = touchedCallback;

        self._materializing = State(initialValue: materialize)
        self.shakeToken = 0;

        if (materialize) {
            card.materialize(once: true, delay: materializeDelay);
        }
    }

    public init(_ card: Card,
                  selectable: Bool = false,
                  materialize: Bool = false,
                  materializeDelay: Double? = nil,
                  askew: Bool = false,
                  alternate: Int? = nil,
                _ touchedCallback: ((TableCard) -> Void)? = nil) {
        self.init(TableCard(card),
                  selectable: selectable, materialize: materialize, materializeDelay: materializeDelay,
                  askew: askew, alternate: alternate, touchedCallback);
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
// TODO: tomorrow (2026-01-18) so i think i want .multiFlip followed by .multiFlip2 (some time/delayed after) ...
			// .flip(card.flipping) // this one does the move with optional fliping on the way
			.multiFlip(card.flipping, count: 2) // same as above i think but simpler?
			// .multiFlip2(card.flipping, flips: 2) // this one just flips around (horizontally) in place - nice
        }
        .onChange(of: card.materializeTrigger) { value in
            self.materializing = true;
            DispatchQueue.main.asyncAfter(deadline: .now() + Defaults.materializeDelay) {
                self.materializing = false;
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

struct FlipEffect: GeometryEffect {
    var flips: Int = 5           // Number of full flips (e.g., 1 = 180°, 2 = 360°, etc.)
    var animatableData: Double

    func effectValue(size: CGSize) -> ProjectionTransform {
        let angle = CGFloat(animatableData) * .pi * CGFloat(flips)
        let transform = CGAffineTransform(translationX: size.width / 2, y: size.height / 2)
            .rotated(by: angle)
            .translatedBy(x: -size.width / 2, y: -size.height / 2)
        return ProjectionTransform(transform)
    }
}

private struct old_FlipEffect: ViewModifier {
    let flipped: Bool
    let axis: (x: CGFloat, y: CGFloat, z: CGFloat)
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(flipped ? 180 : 0),
                axis: axis
            )
            .animation(.linear(duration: 0.4), value: flipped)
    }
}
private struct FlipModifier: AnimatableModifier {
    var target: CGFloat
    var flips: Int
    var duration: Double

    var animatableData: CGFloat {
        get { target }
        set { target = newValue }
    }

    init(flipped: Bool, flips: Int, duration: Double) {
        self.target = flipped ? 1 : 0
        self.flips = flips
        print("FLIPSSSS: \(self.flips)")
        self.duration = duration
    }

    func body(content: Content) -> some View {
        content
            .modifier(FlipEffect(flips: flips, animatableData: target))
            .animation(.linear(duration: duration), value: target)
    }
    let x = 1
}

private extension View {

    fileprivate func skew(_ enabled: Bool = true) -> some View {
        Group { if enabled { self.modifier(SlightRandomRotation()) } else { self } }
    }

    fileprivate func old_flip(_ flipped: Bool, axis: (x: CGFloat, y: CGFloat, z: CGFloat) = (0, 1, 0)) -> some View {
        self.rotation3DEffect(.degrees(flipped ? 180 : 0), axis: axis)
            .animation(.linear(duration: 0.4), value: flipped)
    }
    func flip(_ flipped: Bool, flips: Int = 10, duration: Double = 0.6) -> some View {
        modifier(FlipModifier(flipped: flipped, flips: flips, duration: duration))
    }
    func multiFlip(_ flipped: Bool, count: Int = 2, duration: Double = 0.8) -> some View {
        self.rotation3DEffect(
            .degrees(flipped ? Double(count * 360) : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.linear(duration: duration), value: flipped)
    }
    func multiFlip2(_ flipped: Bool, flips: Int = 1, duration: Double = 0.6) -> some View {
        self.modifier(MultiFlipEffect2(flipped: flipped, flips: flips, duration: duration))
    }
}

struct MultiFlipEffect2: ViewModifier {
    let flipped: Bool
    let flips: Int
    let duration: Double

    @State private var rotation: Double = 0.0

    func body(content: Content) -> some View {
        content
            .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
            .onChange(of: flipped) { value in
                if value {
                    // Delay to ensure this happens *after* layout transition settles
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.linear(duration: duration)) {
                            rotation = Double(flips) * 360
                        }
                    }
                }
            }
    }
}
