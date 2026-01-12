import SwiftUI

public struct CardUI : View {
    
    @ObservedObject var card: TableCard;
                    var new: Bool                                   = false;
                    var nonset: Bool                                = false;
                    var nonsetNonce: Int                            = 0;
                    var askew: Bool                                 = false;
                    var alternate: Int?                             = nil;
                    var cardTouchedCallback: ((TableCard) -> Void)? = nil;

    @State private var fadeInActive: Bool;
    @State private var fadeInDone: Bool;
    @State private var shakeToken: CGFloat;

    init(card: TableCard,
                new: Bool = false,
                nonset: Bool = false,
                nonsetNonce: Int = 0,
                askew: Bool = false,
                alternate: Int? = nil,
                cardTouchedCallback: ((TableCard) -> Void)? = nil) {

        self.card = card;
        self.new = new;
        self.nonset = nonset;
        self.nonsetNonce = nonsetNonce;
        self.askew = askew;
        self.alternate = alternate;
        self.cardTouchedCallback = cardTouchedCallback;

        self.fadeInActive = new;
        self.fadeInDone = false;
        self.shakeToken = 0;
    }

    public var body: some View {
        VStack {
            Button(action: { cardTouchedCallback?(card) }) {
                Image(self.image(card, alternate))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    //
                    // Putting .opacity here rather than below causes
                    // only the inside of the card to blink in/out on SET;
                    // putting it below (where commented out now) makes the
                    // whole card including the border to blink in/out on SET.
                    // Not sure which is better visually; just FYI.
                    //
                    // xyzzy .opacity(new || card.blinkout ? 0.0 : 1.0)
                    .opacity(fadeInActive || card.blinkout ? 0.0 : 1.0)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: card.selected ? 10 : 6)
                            .stroke(card.selected ? Color.red : Color.gray, lineWidth: card.selected ? 3 : 1)
                    )
                    .shadow(color: card.selected ? Color.green : Color.green, radius: card.selected ? 4 : 1)
                    .padding(1)
                    //
                    // These two qualifiers are needed to shake the cards on incorrect SET guess.
                    //
                    .modifier(ShakeEffect(animatableData: nonset ? CGFloat(shakeToken) : 0))
                    .onChange(of: nonsetNonce) { _ in
                        var t = Transaction()
                        t.animation = .linear(duration: 0.85)
                        withTransaction(t) {
                            shakeToken += 1
                        }
                    }
                    //
                    // Keep this transform always present ...
                    //
                    .rotation3DEffect(
                        card.selected ? Angle(degrees: 360) : Angle(degrees: 0),
                        axis: (x: CGFloat(card.selected ? 0 : 1),
                               y: CGFloat(card.selected ? 0 : 1),
                               z: CGFloat(card.selected ? 1 : 0))
                    )
                    //
                    // ... but only animate selection changes, and NEVER during blinking.
                    //
                    .animation(card.blinking ? nil : .linear(duration: 0.20), value: card.selected)
                    //
                    // Optional: Also ensure blinkout toggles don’t animate (belt+suspenders).
                    //
                    .animation(nil, value: card.blinkout)
                    // xyzzy .scaleEffect(new ? 0.05 : 1.0, anchor: .center)
                    .scaleEffect(fadeInActive ? 0.05 : 1.0, anchor: .center)
                    //
                    // See comment above about the placement of this .opacity qualifier.
                    //
                    // xyzzy .opacity(new || card.blinkout ? 0.0 : 1.0)
                    .opacity(fadeInActive || card.blinkout ? 0.0 : 1.0)
                    //
                    // Animation for newly added cards.
                    // - The response argument to the .spring qualifier
                    //   qualifier controls how fast the spring is;
                    //   lower is faster; higher is slower.
                    // - The dampingFraction argument to .spring qualifier
                    //   qualifier controls how flexible/slopping the bounce is;
                    //   lower is bouncier and sloppier; higher is stiffer.
                    //
                    // .animation(.spring(response: 0.70, dampingFraction: 0.40), value: new)
                    .animation(.spring(response: 0.70, dampingFraction: 0.40), value: fadeInActive)
            }
            .skew(askew)
            .onAppear {
                // fadeInActive = new;
                // if (new && !fadeInDone) 
                if (fadeInActive && !fadeInDone) {
                    fadeInDone = true;
                    fadeInActive = true;
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        fadeInActive = false;
                    }
                }
            }
        }
        .onChange(of: card.new) { _ in
            print("CARDUI-ONCHANGE-CARD-NEW")
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

private struct FadeInOnAppear: ViewModifier {
    let enabled: Bool
    let delay: Double
    @State private var active = false
    func body(content: Content) -> some View {
        content
            .scaleEffect(active ? 0.05 : 1.0)
            .animation(.spring(response: 0.7, dampingFraction: 0.4), value: active)
            .onAppear {
                guard enabled else { return }
                active = true
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    active = false
                }
            }
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
