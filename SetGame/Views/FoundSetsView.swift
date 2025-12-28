import SwiftUI

struct FoundSetsView: View {

    let setsLastFound: [[TableCard]];
    let cardsAskew: Bool;

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
                            .slightlyRotated(cardsAskew)
                        if ((j == 2) && (row.count == 3)) { separator(visible: false) }
                    }
                    if (row.count == 3) {
                        DummyCardView()
                        DummyCardView()
                        DummyCardView()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .onChange(of: self.setsLastFound) { setsLastFound in
            if (setsLastFound.count > 0) {
                let setsLastFound: [TableCard] = setsLastFound[setsLastFound.count - 1];
                if (setsLastFound.count == 3){
                    TableView.blinkCards(Array(setsLastFound.prefix(3)), times: 2)
                }
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

private struct DummyCardView: View {
    public var body: some View {
        Image("DUMMY")
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}
