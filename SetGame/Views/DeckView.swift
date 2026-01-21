import SwiftUI

public struct DeckView: View {

    public let cards: [TableCard]

    private let columns: Int    = 6;
    private let marginx: Double = 16;
    private let marginy: Double = 6;
    private let spacing: Double = 6;

    public var body: some View {
        let grid: [GridItem] = Array(repeating: GridItem(spacing: spacing), count: columns);
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: grid, spacing: spacing) {
                ForEach(cards.sorted(), id: \.id) { card in
                    CardView(card, selectable: true)
                }
            }
            .padding(.horizontal, marginx)
            .padding(.vertical, marginy)
        }
        .navigationTitle("\(Defaults.title) Deck")
    }
}
