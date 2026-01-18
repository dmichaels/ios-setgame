import SwiftUI

public struct TestCardView: View {

    @State private var cards: [TableCard] = [
        TableCard("1RHO")!, TableCard("2RHO")!, TableCard("3RHO")!, TableCard("1PSO")!,
        TableCard("1GSD")!, TableCard("2GSD")!, TableCard("3GSD")!, TableCard("2PSO")!,
        TableCard("1PQT")!, TableCard("2PQT")!, TableCard("3PQT")!, TableCard("3PSO")!,
        TableCard("1GSO")!, TableCard("2GSO")!
    ];

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            CardGrid(cards: cards)
            CardControls(cards: cards)
        }
    }

    private struct CardGrid: View  {
        @State var cards: [TableCard];
        let cardsPerRow: Int = 4;
        private let spacing: CGFloat = 8;
        private let marginx: CGFloat = 8;
        private let margint: CGFloat = 12;
        public var body: some View {
            let spacingx: CGFloat = spacing;
            let spacingy: CGFloat = spacing;
            HStack(spacing: marginx) {
                let columns: Array<GridItem> = Array(
                    repeating: GridItem(.flexible(), spacing: spacing),
                    count: cardsPerRow
                )
                Spacer()
                LazyVGrid(columns: columns, spacing: spacing) {
                    ForEach(cards, id: \.id) { card in
                        CardView(card)
                    }
                }
                Spacer()
            }.padding(.top, margint)
        }
    }

    private struct CardControls: View  {
        @State var cards: [TableCard];
        private let spacing: CGFloat = 6;
        private let margint: CGFloat = 12;
        public var body: some View {
            HStack(spacing: spacing) {
                Button {
                    cards.select(toggle: true);
                } label: { Text("Select") }.buttonStyle(.borderedProminent)
                .padding(.leading, 16)
                Button {
                    cards.blink(count: 5, interval: 0.15) {
                        print("CARD BLINKING DONE!")
                    }
                } label: { Text("Blink") }.buttonStyle(.borderedProminent)
                Button {
                    cards.flip(count: 3);
                } label: { Text("Flip") }.buttonStyle(.borderedProminent)
                Button {
                    cards.materialize(speed: 0.9);
                } label: { Text("Fadein") }.buttonStyle(.borderedProminent)
                Button {
                    cards.shake();
                } label: { Text("Shake") }.buttonStyle(.borderedProminent)
                Spacer()
            }.padding(.top, margint)
        }
    }
}
