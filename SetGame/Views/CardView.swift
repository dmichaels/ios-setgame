
import SwiftUI

public struct CardView : View {
    
    @ObservedObject var card: TableCard;
                    var selectable: Bool                        = false;
                    var askew: Bool                             = false;
                    var alternate: Int?                         = nil;
                    var touchedCallback: ((TableCard) -> Void)? = nil;

    private struct MaterializeLimits {
        public static let durationMin: Double   = 0.05;
        public static let durationMax: Double   = 2.00;
        public static let elasticityMin: Double = 0.0;
        public static let elasticityMax: Double = 1.0;
    }

    public enum InitialEffect {

        case none;
        case materialize(duration: Double = Defaults.Effects.materializeDuration,
                         elasticity: Double = Defaults.Effects.materializeElasticity,
                         delay: DelayBy? = nil);

        fileprivate var materialize: Bool {
            if case .materialize = self { true } else { false }
        }

        fileprivate var materializeDuration: Double {
            if case let .materialize(duration, _, _) = self {
                duration;
            }
            else {
                MaterializeLimits.durationMin;
            }
        }

        fileprivate var materializeElasticity: Double {
            if case let .materialize(_, elasticity, _) = self {
                elasticity;
            }
            else {
                MaterializeLimits.elasticityMin;
            }
        }

        fileprivate var materializeDelay: DelayBy? {
            if case let .materialize(_, _, delay) = self { delay } else { nil }
        }
    }

    private static func springDamping(elasticity: Double) -> Double {

        // Computes the SwiftUI dampingFraction value for the .spring
        // qualifier for the materialization (fading in) functionality.
        // Externally advertise "elasticity" as 0.0...1.0 where 0.0 is least
        // elastic and 1.0 is most elastic; but from SwiftUI POV it is reversed.

        let elasticity: Double = min(max(elasticity, MaterializeLimits.elasticityMin), MaterializeLimits.elasticityMax);

        let dampingFractionMin: Double = 0.05;
        let dampingFractionMax: Double = 1.00;
        let dampingFraction: Double = MaterializeLimits.elasticityMax - elasticity;

        return min(max(dampingFraction, dampingFractionMin), dampingFractionMax);
    }

    private static func springResponse(duration: Double, damping: Double) -> Double {

        // Computes the SwiftUI response value for the .spring
        // qualifier for the materialization (fading in) functionality.
        // The given damping value is the SwiftUI dampingFraction
        // based value, i.e from the above springDamping function.
        //
        // From ChatGPT ...
        // Adjust response to compensate for bounce stretching time
        // Bouncier (lower damping) → lower response needed to keep duration similar

        let durationMin: Double = 0.1;
        let durationMax: Double = 2.0;
        let duration = max(0.2, min(duration, 2.0));

        let responseMin: Double = 0.05;
        let responseMax: Double = 1.00;
        let responseAdjustment = 0.85 + 0.3 * (1.0 - damping); // 0.85...1.15
        let response = duration / responseAdjustment

        return response;
    }

    @State private var blinking: Bool;
    @State private var blinkoff: Bool;
    @State private var shakeToken: CGFloat;
    @State private var materializing: Bool;
    @State private var initialEffect: InitialEffect;

    public init(_ card: TableCard,
                  selectable: Bool = false,
                  initialEffect: InitialEffect = .none,
                  askew: Bool = false,
                  alternate: Int? = nil,
                _ touchedCallback: ((TableCard) -> Void)? = nil) {

        self.card = card;
        self.selectable = selectable;
        self.askew = askew;
        self.alternate = alternate;
        self.touchedCallback = touchedCallback;

        self.blinking = false;
        self.blinkoff = false;
        self.shakeToken = 0;

        self.initialEffect = initialEffect;
        //
        // IMPORTANT NOTE:
        // This assighment to the materializing state variable MUST go LAST in init!
        // Still not 100% sure I undstand whey; but does not work unless this is last in init.
        //
        self._materializing = State(initialValue: initialEffect.materialize);
    }

    public init(_ card: Card,
                  selectable: Bool = false,
                  initialEffect: InitialEffect = .none,
                  askew: Bool = false,
                  alternate: Int? = nil,
                _ touchedCallback: ((TableCard) -> Void)? = nil) {
        self.init(TableCard(card),
                  selectable: selectable, initialEffect: initialEffect,
                  askew: askew, alternate: alternate, touchedCallback);
    }

    public var body: some View {
        VStack {
            Button(action: {
                if (self.selectable) {
                    card.selected.toggle();
                }
                self.touchedCallback?(card)
            }) {
                Image(self.image(card, self.alternate))
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
                        ShakeEffect(count: CGFloat(card.shakeCount),
                                    animatableData: CGFloat(shakeToken))
                    )
                    .onChange(of: card.shakeTrigger) { value in
                        var t = Transaction();
                        t.animation = .linear(duration: card.shakeDuration);
                        withTransaction(t) {
                            self.shakeToken += 1;
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
                    .animation(self.blinking ? nil : .linear(duration: 0.20), value: card.selected)
                    .animation(nil, value: self.blinkoff)
                    //
                    // Optional: Also ensure blinkoff toggles don’t animate (belt+suspenders).
                    //
                    .scaleEffect(self.materializing ? 0.05 : 1.0, anchor: .center)
                    //
                    // Placing this opacity qualifier here (rather than higher up above) ensures
                    // that the entire card - including it selection border if present - blinks.
                    //
                    .opacity(self.blinkoff ? 0.0 : 1.0)
            }
            .skew(self.askew)
            //
            // N.B. This flip modifier NOT ONLY does (x-axis) flips; it ALSO MOVES the card
            // if this is called (i.e. by incrementing card.flipTrigger) on u TableCard in
            // a LazyVGrid (like we have in TableView); the flipTrigger should be updated
            // immediately after the assignment to the new slot in the TableCard array
            // used by the LazyVGrid; this seems like it is almost like MAGIC.
            // 
			.flip(card.flipTrigger, count: card.flipCount, duration: card.flipDuration, left: card.flipLeft)
        }
        .onChange(of: card.materializeTrigger) { value in
            self.materializing = true;
            //
            // Note no materializeDelay used here; if we want a delay
            // for on-demand (i.e. not on-appear) materialization
            // then use the delay argument in TableCard.materialize.
            //
            Delay {
                //
                // Animation for newly added "materialized" cards.
                // - The response argument to the .spring qualifier
                //   qualifier controls how fast the spring is;
                //   the lower the faster; the higher the slower.
                // - The dampingFraction argument to .spring qualifier
                //   qualifier controls how flexible/elastic the bounce is;
                //   the lower the bouncier/elastic; the higher the more rigid.
                //   If it is very low (close to zero) it is VERY bouncy indeed;
                //   and in fact if it is zero (ChatGPT at least) says it could lead
                //   to undefined behavior or even a crash (TODO: enforce prevent this).
                //
                let damping: Double = CardView.springDamping(elasticity: card.materializeElasticity);
                let response: Double = CardView.springResponse(duration: card.materializeDuration, damping: damping);
                withAnimation(.spring(response: response, dampingFraction: damping)) {
                    self.materializing = false;
                }
            }
        }
        .onChange(of: card.blinkTrigger) { _ in
            var nblinks: Int = card.blinkCount;
            var niterations: Int = nblinks * 2;
            func blink() {
                niterations -= 1 ; if (niterations <= 0) {
                    self.blinkoff = false;
                    self.blinking = false;
                    if let blinkDoneCallback = card.blinkDoneCallback {
                        DispatchQueue.main.async {
                            blinkDoneCallback();
                        }
                    }
                    return;
                }
                if (self.blinkoff) {
                    self.blinkoff = false;
                    DispatchQueue.main.asyncAfter(deadline: .now() + card.blinkInterval) {
                        blink();
                    }
                }
                else {
                    self.blinkoff = true;
                    DispatchQueue.main.asyncAfter(deadline: .now() + card.blinkoffInterval) {
                        blink();
                    }
                }
            }
            blink();
        }
        .onAppear {
            guard self.materializing else { return }
            let damping: Double = CardView.springDamping(elasticity: self.initialEffect.materializeElasticity);
            let response: Double = CardView.springResponse(duration: self.initialEffect.materializeDuration, damping: damping);
            Delay(by: self.initialEffect.materializeDelay) {
                withAnimation(.spring(response: response, dampingFraction: damping)) {
                    self.materializing = false;
                }
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
            case 0:  return card.code;
            case 1:  return "ALTD_\(card.code)";
            case 2:  return "ALTNC_\(card.code)";
            default: return card.code;
        }
    }
}

extension CardView.InitialEffect {
    static let materialize: CardView.InitialEffect = .materialize();
}

/*
extension CardView.OnAppearEffect {
    static let materialize: CardView.OnAppearEffect = .materialize();
}
*/

private struct ShakeEffect: GeometryEffect {
    var count: CGFloat = 9.0
    var angle: CGFloat = 8.0
    var animatableData: CGFloat
    func effectValue(size: CGSize) -> ProjectionTransform {
        let a = angle * sin(animatableData * .pi * 2 * count)
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

private extension View {

    fileprivate func skew(_ enabled: Bool = true) -> some View {
        Group { if enabled { self.modifier(SlightRandomRotation()) } else { self } }
    }

    fileprivate func flip(_ trigger: Int, count: Int = 2, duration: Double = 0.6, left: Bool = false) -> some View {
        self.rotation3DEffect(.degrees(Double(trigger * count * 180) * (left ? -1 : 1)),
                               axis: (x: 0, y: 1, z: 0))
            .animation(.linear(duration: duration), value: trigger)
    }
}
