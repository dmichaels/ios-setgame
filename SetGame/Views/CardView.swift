import SwiftUI

public struct CardView : View {
    
    @ObservedObject var card : TableCard;

    var touchedCallback : ((TableCard) -> Void)?

    public var body : some View {
        VStack {
            Button(action: {touchedCallback?(card)}) {
            Image(card.codename)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .rotation3DEffect(card.selected && !card.blinking
                                  ? Angle(degrees: 720)
                                  : (card.selected
                                     ? Angle(degrees: 360)
                                     : Angle(degrees: 0)),
                                  axis: (x: CGFloat(0),
                                         y: CGFloat(card.selected && !card.blinking ? 0 : 1),
                                         z: CGFloat(card.selected && !card.blinking ? 1 : 0)))
                .opacity(card.blink ? 0.0 : 1.0)
                .animation(card.blinking ? nil : Animation.linear(duration: 0.3))
            .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius:card.selected ? 10 : 6)
                         .stroke(card.selected ? Color.red : Color.gray, lineWidth: card.selected ? 3 : 1))
                .shadow(color: card.selected ? Color.green : Color.blue, radius: card.selected ? 3 : 1)
                .padding(1)
                .onTapGesture {
                    touchedCallback?(card);
                }
            }
        }
    }
}

extension View {
    func slightlyRotated(_ enabled: Bool = true) -> some View {
        Group { if enabled { self.modifier(SlightRandomRotation()) } else { self } }
    }
}

public struct SlightRandomRotation: ViewModifier {
    @State private var angle: Double = Double(Int.random(in: -2...2))
    public func body(content: Content) -> some View {
        content.rotationEffect(.degrees(angle));
    }
}

/*
struct CardView_Previews: PreviewProvider {
    static func touchedCallback(_ card : TableCard) {
        card.selected.toggle();
    }
    static var previews: some View {
        let _ : TableCard = TableCard("PQT3")!;
        CardView(card: TableCard(), touchedCallback: touchedCallback);
    }
}
*/
