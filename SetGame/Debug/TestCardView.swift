import SwiftUI

public struct TestCardView: View {
    public let table: TestTable = TestTable()
    public var body: some View {
        TestView(table: table)
    }
}

public class TestTable: ObservableObject {

    @Published public /*private(set)*/ var cards: [TableCard]!;

    private var moveTo: Int = 0;

    init() {
        self.cards = [
            TableCard("1RHO")!, TableCard("2RHO")!, TableCard("3RHO")!, TableCard("1PSO")!,
            TableCard("1GSD")!, TableCard("2GSD")!, TableCard("3GSD")!, TableCard("2PSO")!,
            TableCard("1PQT")!, TableCard("2PQT")!, TableCard("3PQT")!, TableCard("3PSO")!,
            TableCard("1GSO")!, TableCard("2GSO")!
        ];
    }

    public var moveEnabled: Bool { (self.cards.count > 1) && (self.moveTo < (self.cards.count - 1)) }

    public func move() {
        guard self.moveEnabled else { return }
        let moveFrom: Int = self.cards.count - 1;
        self.cards[moveTo] = self.cards[moveFrom];
        self.cards.remove(at: moveFrom);
        self.cards[moveTo].flip();
        self.moveTo += 1;
        if (self.moveTo >= (self.cards.count - 1)) {
            self.moveTo = 0;
        }
    }

    public func x() {
        self.cards.swapAt(0, 3);
        [self.cards[0], self.cards[3]].flip();
    }
}

public struct TestView: View {

    public init(table: TestTable) {
        self.table = table;
    }

    @ObservedObject public var table: TestTable;

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            CardGrid(table: table)
            CardControls(table: table)
        }
    }

    private struct CardGrid: View  {
        @ObservedObject public var table: TestTable;
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
                    ForEach(table.cards, id: \.id) { card in
                        CardView(card, selectable: true)
                    }
                }
                Spacer()
            }.padding(.top, margint)
        }
    }

    private struct CardControls: View  {
        @ObservedObject public var table: TestTable;
        private let spacing: CGFloat = 5;
        private let margint: CGFloat = 12;
        public var body: some View {
            HStack(spacing: spacing) {
                Control(label: "Select") { table.cards.select(toggle: true) }
                Control(label: "Blink")  { table.cards.blink(count: 5, interval: 0.15) }
                Control(label: "Flip")   { table.cards.flip() }
                Control(label: "Fade")   { table.cards.materialize(speed: 0.9) }
                Control(label: "Shake")  { table.cards.shake() }
                Control(label: "Move")   { table.move() }.disabled(!table.moveEnabled)
                Control(label: "X")   { table.x(); }
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
    }
}
