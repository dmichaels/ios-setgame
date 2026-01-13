import SwiftUI

struct FoundSetsView: View {

    @EnvironmentObject var settings : Settings;

    let setsLastFound: [[TableCard]];
    let cardsAskew: Bool;

    @State var showHelpButton: Bool = false;
    @State var xyzzynew: Bool = true;

    var body: some View {
        let rows: [[TableCard]] = pairCardsListForDisplay(setsLastFound.reversed());
        if ((rows.count == 0) && !self.settings.hideHelpButton){
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

        Button(action: {
            if ((setsLastFound.count > 0) && (setsLastFound[0].count > 0)) {
                print("BUTTON")
                // setsLastFound[0][0].new = true
                setsLastFound[0][0].fadein();
                /*
                for cards in setsLastFound {
                    for card in cards {
                        card.new = true
                    }
                }
                */
            }
        }) { Text("HELLO") }

        VStack(alignment: .leading, spacing: 8) {
            ForEach(rows.indices, id: \.self) { i in
                let row: [TableCard] = rows[i];
                HStack {
                    ForEach(row.indices, id: \.self) { j in
                        let card: TableCard = row[j];
                        if (j == 3) { separator(visible: true) }
                        /*
                        CardUI(card: card,
                               new: true,
                               askew: settings.cardsAskew,
                               alternate: settings.alternateCards)
                        */
                        CardUI(card: card,
                               // xyzzy new: xyzzynew,
                               new: true,
                               askew: settings.cardsAskew,
                               alternate: 2 /*settings.alternateCards*/)
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
                    TableCardEffects.blinkCards(Array(setsLastFound.prefix(3)), times: 2)
                }
/*
                print("xyzzy: \(xyzzynew)")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                print("xyzzy-set-false: \(xyzzynew)")
                                xyzzynew = false
                print("xyzzy-set-false-done: \(xyzzynew)")
                            }
*/
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
