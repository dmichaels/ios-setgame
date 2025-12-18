import SwiftUI

struct DeckView: View {

    let cards: [Card];

    private let cardWidth: CGFloat = 56;

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            let rows: [[Card]] = organizeCardsForDisplay(cards);
            VStack(alignment: .leading, spacing: 8) {
                ForEach(rows.indices, id: \.self) { i in
                    let row: [Card] = rows[i];
                    HStack {
                        ForEach(row.indices, id: \.self) { j in
                            let card: Card = row[j];
                            CardView(card: TableCard(card))
                                .frame(width: cardWidth)
                        }
                    }
                }
            }.padding()
        }.navigationTitle("SET Deck") // SET Game® Deck
    }

    private func organizeCardsForDisplay(_ cards: [Card]) -> [[Card]] {
        let cards: [Card] = cards.sorted();
        var result: [[Card]] = [];
        var i: Int = 0;
        for i in 0..<cards.count {
            if (i % 6 == 0) {
                result.append([]);
            }
            result[result.count - 1].append(cards[i]);
        }
        return result;
    }
}
