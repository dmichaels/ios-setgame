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

    var touchedCallback : ((TableCard) -> Void)?

    public var body : some View {
        if (card.blinking) {
            //
            // ODDITY:
            // Had to duplicate this whole thing here, WITHOUT the rotation3DEffect animation
            // modifiers, for the blinking state; i.e. where we have found a SET and we want to
            // blink the 3 SET cards on/off a few times; without this we will see the rotation
            // and flipping thing as a part of the blinking (only on the last SET card selected
            // actually for some reason), even if we conditionally choose non-rotation/flipping
            // values for the rotation3DEffect based on card.blinking.
            //
            VStack {
                Button(action: { touchedCallback?(card) }) {
                    Image(self.image(card))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .opacity(card.blinkout ? 0.0 : 1.0)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: card.selected ? 10 : 6)
                                .stroke(card.selected ? Color.red : Color.gray, lineWidth: card.selected ? 3 : 1))
                        .shadow(color: card.selected ? Color.green : Color.blue, radius: card.selected ? 3 : 1)
                        .padding(1)
                }
            }
        }
        else if (false) {
            VStack {
                Button(action: { touchedCallback?(card) }) {
                Image(self.image(card))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .rotation3DEffect(card.selected ? Angle(degrees: 720) : Angle(degrees: 0),
                                      axis: (x: CGFloat(0),
                                             y: CGFloat(card.selected ? 0 : 1),
                                             z: CGFloat(card.selected ? 1 : 0)))
                    .animation(Animation.linear(duration: 0.3))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: card.selected ? 10 : 6)
                            .stroke(card.selected ? Color.red : Color.gray, lineWidth: card.selected ? 3 : 1))
                    .shadow(color: card.selected ? Color.green : Color.blue, radius: card.selected ? 3 : 1)
                    .padding(1)
                    //
                    // FYI: Move the rotation3DEffect and animation here to get a more robust effect;
                    // where it looks like the whole card including border is spinning around.
                    //
                }
            }
        }
        else {
            VStack {
                Button(action: { touchedCallback?(card) }) {
                Image(self.image(card))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    //
                    // FYI: Move the rotation3DEffect and animation here to get a less robust effect;
                    // where it looks like the just the inner parf of the card is spinning around.
                    //
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: card.selected ? 10 : 6)
                            .stroke(card.selected ? Color.red : Color.gray, lineWidth: card.selected ? 3 : 1))
                    .shadow(color: card.selected ? Color.green : Color.blue, radius: card.selected ? 3 : 1)
                    .padding(1)
                    .rotation3DEffect(card.selected ? Angle(degrees: 360) : Angle(degrees: 0),
                                      axis: (x: CGFloat(card.selected ? 0 : 1),
                                             y: CGFloat(card.selected ? 0 : 1),
                                             z: CGFloat(card.selected ? 1 : 0)))
                    .animation(Animation.linear(duration: 0.20))
                }
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
    static var popInCard: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.05, anchor: .center)
                .combined(with: .opacity),
            removal: .opacity
        )
    }
}
