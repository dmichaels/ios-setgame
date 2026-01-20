import SwiftUI

public struct TestCardGridView: View {

    @ObservedObject var table : Table;
    @ObservedObject var settings : Settings;

    public init(table: Table, settings: Settings) {
        self.table = table;
        self.settings = settings;

        /*
        self.table.addCards([
            TableCard("1RHO")!, TableCard("2RHO")!, TableCard("3RHO")!, TableCard("1PSO")!,
            TableCard("1GSD")!, TableCard("2GSD")!, TableCard("3GSD")!, TableCard("2PSO")!,
            TableCard("1PQT")!, TableCard("2PQT")!, TableCard("3PQT")!, TableCard("3PSO")!,
            TableCard("1GSO")!, TableCard("2GSO")!
        ]);
        */
    }

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            CardGridView(table: table, settings: settings)
            CardControls(table: table)
        }
        .onAppear {
            self.table.addCards([
                TableCard("1RHO")!, TableCard("2RHO")!, TableCard("3RHO")!, TableCard("1PSO")!,
                TableCard("1GSD")!, TableCard("2GSD")!, TableCard("3GSD")!, TableCard("2PSO")!,
                TableCard("1PQT")!, TableCard("2PQT")!, TableCard("3PQT")!, TableCard("3PSO")!,
                TableCard("1GSO")!, TableCard("2GSO")!
            ]);
        }
    }

    private struct CardControls: View  {

        @ObservedObject public var table: Table;

        private let spacing: CGFloat = 5;
        private let margint: CGFloat = 12;

        public var body: some View {
            HStack(spacing: spacing) {
                Control(label: "Select") { self.table.cards.select(toggle: true) }
                Control(label: "Blink")  { self.table.cards.blink(count: 5, interval: 0.15) }
                Control(label: "Flip")   { self.table.cards.flip() }
                Control(label: "Fade")   { self.table.cards.materialize(speed: 0.9) }
                Control(label: "Shake")  { self.table.cards.shake() }
                Control(label: "Move")   { self.move() }.disabled(!self.moveEnabled)
            }.padding(.top, margint)
        }

        private struct Control: View  {
            var label: String;
            var callback: () -> Void;
            public var body: some View {
                Button {
                    callback();
                } label: { Text(label).font(.footnote) }.buttonStyle(.borderedProminent)
            }
        }

        @State private var moveTo: Int = 0;
        private var moveEnabled: Bool { (self.table.cards.count > 1) &&
                                        (self.moveTo < (self.table.cards.count - 1)) }
        private func move() {
            guard self.moveEnabled else { return }
            let moveFrom: Int = self.table.cards.count - 1;
            self.table.swapCards(at: moveTo, and: moveFrom);
            self.table.removeCard(at: moveFrom);
            self.table.cards[moveTo].flip();
            self.moveTo += 1;
            if (self.moveTo >= (self.table.cards.count - 1)) {
                self.moveTo = 0;
            }
        }
    }
}
