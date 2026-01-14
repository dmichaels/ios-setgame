import SwiftUI

struct FoundSetsView: View {

    @EnvironmentObject var settings : Settings;

    let setsLastFound: [[TableCard]];
    let cardsAskew: Bool;

    @State var showHelpButton: Bool = false;

    var body: some View {
        let rows: [[TableCard]] = pairCardsListForDisplay(setsLastFound.reversed());
        if ((rows.count == 0) && !self.settings.hideHelpButton) {
            Spacer()
            HelpViewButton {
                showHelpButton = true
            }
            NavigationLink(
                destination: HelpView(),
                isActive: $showHelpButton
            ) {
                EmptyView()
            }
        }
        Spacer()
        let first: [TableCard] = (rows.count > 0) && (rows[0].count > 0) ? Array(rows[0].prefix(3)) : []
        VStack(alignment: .leading, spacing: 8) {
            TestView()
            ForEach(rows.indices, id: \.self) { i in
                let row: [TableCard] = rows[i]
                let left: [TableCard]  = Array(row.prefix(3))
                let right: [TableCard] = Array(row.dropFirst(3)) 
                HStack {
                    ForEach(left, id: \.id) { card in
                        CardUI(card,
                               materialize: first.contains(card),
                               askew: settings.cardsAskew,
                               alternate: settings.alternateCards)
                    }
                    separator(
                        visible: !right.isEmpty
                    )
                    ForEach(right, id: \.id) { card in
                        CardUI(card,
                               materialize: first.contains(card),
                               askew: settings.cardsAskew,
                               alternate: settings.alternateCards)
                    }
            		if (right.isEmpty) {
                		DummyCardView()
                		DummyCardView()
                		DummyCardView()
            		}
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

private struct TestView: View {
    @EnvironmentObject var settings : Settings;
    @State var cards: [TableCard] = [ TableCard("1RHO")!, TableCard("2GSD")!, TableCard("3PTQ")!]
    public var body: some View {
        VStack {
            HStack {
                ForEach(cards.indices, id: \.self) { i in
                    CardUI(
                        cards[i],
                        // materialize: true,
                        materialize: i == 0 || i == 2 ,
                        alternate: settings.alternateCards
                    )
                    .frame(width: 100)
                }
            }
            HStack {
                Button {
                    print("button-select> selected: \(cards[0].selected) \(cards[1].selected) \(cards[2].selected)")
                    cards.select(toggle: true);
                } label: { Text("Select") }.buttonStyle(.borderedProminent)

                Button {
                    cards.blink(count: 5, interval: 0.15) {
                        print("CARD BLINKING DONE!")
                    }
                } label: { Text("Blink") }.buttonStyle(.borderedProminent)

                Button {
                    cards.materialize(speed: 0.9);
                } label: { Text("Materialize") }.buttonStyle(.borderedProminent)

                Button {
                    print("button-shake-a> shaking: \(cards[0].shaking) \(cards[1].shaking) \(cards[2].shaking)")
                    cards.shake();
                    print("button-shake-b> shaking: \(cards[0].shaking) \(cards[1].shaking) \(cards[2].shaking)")
                } label: { Text("Shake") }.buttonStyle(.borderedProminent)
            }
        }
    }
}
