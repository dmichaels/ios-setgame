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
    @State private var shake: CGFloat = 0;
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
                    // This qualifier is only needed if we want to shake the entire
                    // table on an incorrect SET guess (i.e. settings.shakeTableOnNonSet).
                    //
/*
                    .modifier(ShakeEffect(animatableData: shake))
                    //
                    // These two qualifiers do the shaking of the selected cards on an incorrect SET guess.
                    //
                    .modifier(ShakeEffect(animatableData: nonset ? CGFloat(table.state.nonsetNonce) : 0))
                    .animation(.linear(duration: 0.45), value: table.state.nonsetNonce)
*/
.modifier(
    CenteredRotationalShakeEffect(
        maxAngle: 2.8,
        maxTranslation: 8.0,
        shakesPerUnit: 10.0,
        animatableData: nonset ? CGFloat(table.state.nonsetNonce) : 0
    )
)
.animation(.easeOut(duration: 1.1), value: table.state.nonsetNonce)
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
                    //   lower is e bouncier and sloppier; higher is stiffer.
                    //
                    .animation(.spring(response: 0.58, dampingFraction: 0.54), value: new)
            }
            //
            // This is only needed if we want to shake the entire table
            // on an incorrect SET guess (i.e. settings.shakeTableOnNonSet).
            //
            .onChange(of: table.state.setJustFoundNot) { wrong in
                guard wrong && settings.shakeTableOnNonSet else { return }
                withAnimation(.linear(duration: 0.35)) { shake += 1 }
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

struct ShakeEffect: GeometryEffect {
    //
    // Used for shaking the whole table OR just the selected
    // cards on the table (on an incorrect SET guess).
    //
    var amplitude: CGFloat = 10;    // points left/right
    var shakesPerUnit: CGFloat = 3; // how many oscillations
    var animatableData: CGFloat;    // drive this from a changing value
    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = amplitude * sin(animatableData * .pi * 2 * shakesPerUnit);
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0));
    }
}

struct RotationalShakeEffect: GeometryEffect {

    var maxAngle: CGFloat = 6        // degrees left/right
    var maxTranslation: CGFloat = 4  // optional, subtle
    var shakesPerUnit: CGFloat = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        let phase = animatableData * .pi * 2 * shakesPerUnit
        let rotation = sin(phase) * maxAngle
        let translation = sin(phase) * maxTranslation

        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: translation, y: 0)
        transform = transform.rotated(by: rotation * .pi / 180)

        return ProjectionTransform(transform)
    }
}

struct CenteredRotationalShakeEffect: GeometryEffect {

    var maxAngle: CGFloat = 6        // degrees
    var maxTranslation: CGFloat = 3  // subtle lateral motion
    var shakesPerUnit: CGFloat = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {

        let phase = animatableData * .pi * 2 * shakesPerUnit
        let angle = sin(phase) * maxAngle * .pi / 180
        let translation = sin(phase) * maxTranslation

        let centerX = size.width / 2
        let centerY = size.height / 2

        var transform = CGAffineTransform.identity

        // Move origin to center
        transform = transform.translatedBy(x: centerX, y: centerY)

        // Rotate around center
        transform = transform.rotated(by: angle)

        // Optional micro-translation (still feels physical)
        transform = transform.translatedBy(x: translation, y: 0)

        // Move back
        transform = transform.translatedBy(x: -centerX, y: -centerY)

        return ProjectionTransform(transform)
    }
}
