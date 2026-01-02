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

    var cardTouchedCallback : ((TableCard) -> Void)?

    public var body: some View {
        let new: Bool = !table.state.blinking && table.state.newcomers.contains(card.id);
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
                    .shadow(color: card.selected ? Color.green : Color.blue, radius: card.selected ? 3 : 1)
                    .padding(1)
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
                    .animation(.spring(response: 0.22, dampingFraction: 0.82), value: new)
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
        switch self.table.settings.alternateCards {
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

extension AnyTransition {
    static var XYZZY_UNUSED_CURRENTLY_popInCard: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.05, anchor: .center)
                .combined(with: .opacity),
            removal: .opacity
        )
    }
}
