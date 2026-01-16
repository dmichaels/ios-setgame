import SwiftUI

struct FoundSetsView: View {

    private let setsLastFound: [[TableCard]];
    @ObservedObject
    private var settings: Settings;

    init(setsLastFound: [[TableCard]], settings: Settings) {
        self.setsLastFound = setsLastFound;
        self.settings = settings;
    }

    var body: some View {
        let sets: [[TableCard]] = organizeSetsForDisplay(setsLastFound.reversed());
        let mostRecentSet: Set<String> = mostRecentSet(setsLastFound);
        VStack {
            HelpBar(visible: sets.isEmpty && !self.settings.hideHelpButton)
            Spacer()
            VStack(alignment: .leading, spacing: 0) {
                ForEach(sets.indices, id: \.self) { i in
                    let left: [TableCard] = Array(sets[i].prefix(3));
                    let right: [TableCard] = Array(sets[i].dropFirst(3));
                    HStack {
                        SetView(set: left, recent: mostRecentSet, settings: settings)
                        Separator(visible: !right.isEmpty)
                        SetView(set: right, recent: [], settings: settings)
                        DummySetView(visible: right.isEmpty)
                    }
                }
                TestView()
            }
        }
    }

    private func organizeSetsForDisplay(_ setsLastFound: [[TableCard]]) -> [[TableCard]] {
        var result: [[TableCard]] = [];
        var i: Int = 0;
        while (i < setsLastFound.count) {
            if ((i + 1) < setsLastFound.count) {
                result.append(setsLastFound[i].sorted() + setsLastFound[i + 1].sorted());
            } else {
                result.append(setsLastFound[i].sorted());
            }
            i += 2;
        }
        return result;
    }

    private func mostRecentSet(_ setsLastFound: [[TableCard]]) -> Set<String> {
        if let mostRecent: [TableCard] = setsLastFound.last {
            return Set(mostRecent.prefix(3).map(\.id))
        }
        return [];
    }

    private struct HelpBar: View {
        var visible: Bool = true;
        @State private var showHelpButton: Bool = false;
        public var body: some View {
            if (visible) {
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
        }
    }

    private struct SetView: View {

                        let set: [TableCard];
                        let recent: Set<String>;
        @ObservedObject var settings: Settings;

        // Note that settings above must be @ObservedObject otherwise the cards will not
        // visually update properly if the user changes the card images via SettingsView.

        init(set: [TableCard], recent: Set<String>, settings: Settings) {
            self.set = set;
            self.recent = recent;
            self.settings = settings;
        }

        let blink: Bool       = true;
        let materialize: Bool = false;
        let shake: Bool       = true;

        public var body: some View {
            ForEach(set, id: \.id) { card in
                //
                // IMPORTANT NOTE:
                // We must create a copy of TableCard here so
                // that the special materializeOnce gets reset.
                //
                let card: TableCard = TableCard(card);
                let recent: Bool = recent.contains(card.id);
                CardUI(
                    card,
                    materialize: materialize && recent,
                    askew: settings.cardsAskew,
                    alternate: settings.alternateCards
                )
                .onAppear {
                    if (recent) {
                        if (blink) {
                            card.blink(count: 3, interval: 0.14, delay: 0.1);
                        }
                        if (shake) {
                            card.shake(count: 12, speed: 1.2, delay: 0.7);
                        }
                    }
                }
            }
        }
    }

    private struct Separator: View {
        var visible: Bool = true;
        public var body: some View {
            if (visible) {
                let diamondWidth: CGFloat = 6;
                Text("\u{2756} ")
                    .font(.system(size: 8))
                    .frame(width: diamondWidth)
                    .foregroundColor(visible ? .secondary : .clear);
            }
        }
    }

    private struct DummySetView: View {
        private struct DummyCardView: View {
            public var body: some View {
                Image("DUMMY")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        var visible: Bool = true;
        public var body: some View {
            if (visible) {
                DummyCardView()
                DummyCardView()
                DummyCardView()
            }
        }
    }
}

private struct TestView: View {
    @EnvironmentObject private var settings : Settings;
    @State private var cards: [TableCard] = [ TableCard("1RHO")!, TableCard("2GSD")!, TableCard("3PTQ")!]
    public var body: some View {
        VStack {
            HStack {
                ForEach(cards.indices, id: \.self) { i in
                    CardUI(
                        cards[i],
                        materialize: i == 0 || i == 2,
                        alternate: settings.alternateCards
                    )
                    .frame(width: 100)
                }
            }
            HStack {
                Button {
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
                    cards.shake();
                } label: { Text("Shake") }.buttonStyle(.borderedProminent)
            }
        }
    }
}
