import SwiftUI

public struct FoundSetsView: View {

    @ObservedObject private var table: Table;
    @ObservedObject private var settings: Settings;

    init(table: Table, settings: Settings) {
        self.table = table;
        self.settings = settings;
    }

    private var sets: [[TableCard]] { table.state.setsLastFound }
    private var recent: [TableCard]? { self.sets.last?.sorted() }
    private var blink: Bool = false;
    private var shake: Bool = true;

    public var body: some View {
        let sets: [[TableCard]] = self.organizeSetsForDisplay(self.sets);
        VStack {
            HelpBar(visible: sets.isEmpty && !self.settings.hideHelpButton)
            Space(size: 12)
            //
            // The VStack spacing here is the amount of
            // space vertically between the rows of cards.
            //
            VStack(alignment: .leading, spacing: 8) {
                ForEach(sets.indices, id: \.self) { i in
                    let left: [TableCard] = sets[i].first(3);
                    let right: [TableCard] = sets[i].first(-3);
                    //
                    // The HStack spacing here is the amount
                    // of space horizontally between the cards.
                    //
                    HStack(spacing: 6) {
                        //
                        // Note that the most recent set is always in the left column.
                        //
                        SetView(set: left, recent: left == self.recent, settings: settings)
                        Separator(visible: !right.isEmpty)
                        SetView(set: right, recent: false, settings: settings)
                        DummySetView(visible: right.isEmpty)
                    }
                }
            }
        }
        .onChange(of: self.table.state.setsLastFound) { value in
            if (self.blink) {
                self.recent?.blink(count: 3, interval: 0.14, delay: 1.4);
            }
            else if (self.shake) {
                self.recent?.shake(count: 10, duration: 1.2, delay: 0.6);
            }
        }
    }

    private struct SetView: View {

                        let set: [TableCard];
                        let recent: Bool;
        @ObservedObject var settings: Settings;

        // Note that settings above must be @ObservedObject otherwise the cards will not
        // visually update properly if the user changes the card images via SettingsView.

        let blink: Bool       = false;
        let materialize: Bool = true;
        let shake: Bool       = false;

        public var body: some View {
            ForEach(set, id: \.id) { card in
                CardView(
                    card,
                    selectable: false,
                    materialize: materialize && recent,
                    materializeDelay: 0,
                    askew: settings.cardsAskew,
                    alternate: settings.alternateCards
                )
            }
        }
    }

    private struct Separator: View {
        var visible: Bool = true;
        public var body: some View {
            let diamondWidth: CGFloat = 6;
            Text("\u{2756} ")
                .font(.system(size: 8))
                .frame(width: diamondWidth)
                .foregroundColor(visible ? .secondary : .clear);
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

    private struct HelpBar: View {
        var visible: Bool = true;
        @State private var showHelpButton: Bool = false;
        public var body: some View {
            if (visible) {
                Space(size: 12)
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

    // Given a list of SETS in the form of array of array of TableCard where each array of
    // TableCard within the outer array is the 3 cards comprising a SET, and assuming that
    // the order is most recently found SETs last -- return the list of SETs organized for
    // display such that the cards are (first) reversed in order (so the most recent will
    // appear first), and then as an array of array of 6 cards each, representing the
    // cards for 2 SETs, i.e. so the display can easily visually display 2 SETs per row,
    // the last array in the outer array possibly containing only 3 cards if there are
    // and odd number of SETs; also note that each sequence of 3 SET cards are ordered
    // according to the Comparable interface (on Card from which TableCard is derived).
    //
    private func organizeSetsForDisplay(_ setsLastFound: [[TableCard]]) -> [[TableCard]] {
        let sets: [[TableCard]] = setsLastFound.reversed();
        var result: [[TableCard]] = [];
        var i: Int = 0;
        while (i < sets.count) {
            if ((i + 1) < sets.count) {
                result.append(sets[i].sorted() + sets[i + 1].sorted());
            } else {
                result.append(sets[i].sorted());
            }
            i += 2;
        }
        return result;
    }
}
