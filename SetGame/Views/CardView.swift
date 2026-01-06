import SwiftUI

public struct CardView : View {
    
    @ObservedObject var card : TableCard;
    @EnvironmentObject var table: Table;
    //
    // Note that this @EnvironmentObject Settings declaration needs to
    // be here otherwise when the Settings.alternateCards property is
    // changed it won't update immediately in the FoundSetsView.
    //
    @EnvironmentObject var settings: Settings;
    @State private var shakeToken: CGFloat = 0;
    var cardTouchedCallback : ((TableCard) -> Void)?;
    var alternate : Int?

    public var body: some View {
        let new: Bool = card.newcomer(to: table);
        let nonset: Bool = card.nonset(on: table);
        VStack {
            Button(action: { cardTouchedCallback?(card) }) {
                Image(self.image(card))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    //
                    // Putting .opacity here rather than below causes
                    // only the inside of the card to blink in/out on SET;
                    // putting it below (where commented out now) makes the
                    // whole card including the border to blink in/out on SET.
                    // Not sure which is better visually; just FYI.
                    //
                    .opacity(new || card.blinkout ? 0.0 : 1.0)
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
                    .onChange(of: table.state.nonsetNonce) { _ in
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
                    .scaleEffect(new ? 0.05 : 1.0, anchor: .center)
                    //
                    // See comment above about the placement of this .opacity qualifier.
                    //
                    .opacity(new || card.blinkout ? 0.0 : 1.0)
                    //
                    // Animation for newly added cards.
                    // - The response argument to the .spring qualifier
                    //   qualifier controls how fast the spring is;
                    //   lower is faster; higher is slower.
                    // - The dampingFraction argument to .spring qualifier
                    //   qualifier controls how flexible/slopping the bounce is;
                    //   lower is bouncier and sloppier; higher is stiffer.
                    //
                    .animation(.spring(response: 0.70, dampingFraction: 0.40), value: new)
            }
        }
    }

    private func image(_ card: TableCard) -> String {
        //
        // The default cards are the classic SET Game ones.
        // - Original ones from Java based SET Game circa 1999.
        // The ALTD_ cards are the rectangle color based ones.
        // - See ios-setgame/etc/alternate_cards/alternate_cards_analogous.py
        // The ALTNC_ cards are the monochrome (no-color) based ones.
        // - See ios-setgame/etc/alternate_cards/alternate_cards_no_colors.py
        //
        let alternateCards: Int = self.alternate ?? self.table.settings.alternateCards;
        // switch self.table.settings.alternateCards {
        switch alternateCards {
            case 0:  return card.codename;
            case 1:  return "ALTD_\(card.codename)";
            case 2:  return "ALTNC_\(card.codename)";
            default: return card.codename;
        }
    }
}

extension View {
    func slightlyRotated(_ enabled: Bool = true) -> some View {
        Group { if enabled { self.modifier(SlightRandomRotation()) } else { self } }
    }
}

private struct SlightRandomRotation: ViewModifier {
    @State private var angle: Double = Double(Int.random(in: -2...2))
    public func body(content: Content) -> some View {
        content.rotationEffect(.degrees(angle));
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

private struct HorizontalShakeEffect: GeometryEffect {
    var amplitude: CGFloat = 10      // points left/right
    var shakesPerUnit: CGFloat = 8   // how many oscillations
    var animatableData: CGFloat      // drive this from a changing value
    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = amplitude * sin(animatableData * .pi * 2 * shakesPerUnit)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

private struct RotationalShakeEffect: GeometryEffect {
    //
    // Usage:
    //  .modifier(ShakeEffect(
    //      amplitude: 16,
    //      cycles: 8,
    //      animatableData: nonset ? CGFloat(table.state.nonsetNonce) : 0
    //  ))
    //  .animation(.easeOut(duration: 0.85), value: table.state.nonsetNonce)
    //
    var amplitude: CGFloat = 7
    var cycles: CGFloat = 3
    var animatableData: CGFloat // pass CGFloat(table.state.nonsetNonce)
    func effectValue(size: CGSize) -> ProjectionTransform {
        // Turn animatableData into a 0→1 ramp each time the nonce increments.
        let t = animatableData.truncatingRemainder(dividingBy: 1)
        let envelope = (cos(t * .pi) + 1) / 2   // smooth 1→0
        let angleDeg = sin(t * .pi * 2 * cycles) * amplitude * envelope
        let angle = angleDeg * .pi / 180
        let cx = size.width / 2
        let cy = size.height / 2
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: cx, y: cy)
        transform = transform.rotated(by: angle)
        transform = transform.translatedBy(x: -cx, y: -cy)
        return ProjectionTransform(transform)
    }
}
