
import SwiftUI

struct FoundSetsView: View {

    let setsLastFound: [[TableCard]];
    let cardsAskew: Bool;

    private let cardWidth: CGFloat = 52;

    var body: some View {
        let rows: [[TableCard]] = pairCardsListForDisplay(setsLastFound.reversed());
        Spacer()
        VStack(alignment: .leading, spacing: 8) {
            ForEach(rows.indices, id: \.self) { i in
                let row: [TableCard] = rows[i];
                HStack {
                    ForEach(row.indices, id: \.self) { j in
                        let card: TableCard = row[j];
                        if (j == 3) { separator(visible: true) }
                        CardView(card: card)
                            .frame(width: cardWidth)
                            .slightlyRotated(cardsAskew)
                        if ((j == 2) && (row.count == 3)) { separator(visible: false) }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    @ViewBuilder
    private func separator(visible: Bool) -> some View {
        let diamondWidth: CGFloat = 6;
        Text("\u{2756} ")
            .font(.system(size: 8))
            .frame(width: diamondWidth)
            .foregroundColor(visible ? .secondary : .clear);
    }

    private func pairCardsListForDisplay(_ cardsList: [[TableCard]]) -> [[TableCard]] {
        var result: [[TableCard]] = [];
        var i: Int = 0;
        while (i < cardsList.count) {
            if ((i + 1) < cardsList.count) {
                result.append(cardsList[i].sorted() + cardsList[i + 1].sorted());
            } else {
                result.append(cardsList[i].sorted());
            }
            i += 2;
        }
        return result;
    }
}
