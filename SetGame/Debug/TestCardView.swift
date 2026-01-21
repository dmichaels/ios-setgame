import SwiftUI

public struct TestCardView: View {

    @ObservedObject var settings: Settings;
    @StateObject var table: Table;

    public init(settings: Settings) {
        self.settings = settings
        self._table = StateObject(wrappedValue: Table(settings: settings))
    }

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            CardGridView(table: table, settings: settings)
            CardControls(table: table)
            TextBoxWithButton() { value in
                let cards: [TableCard] = TestCardView.toCards(value);
                self.simulateIncomingDealCardsMessage(cards);
                /*
                for card in cards {
                    self.table.addCard(card);
                }
                */
/*
                for codename in value.split() {
                    if let card: TableCard = TableCard(codename) {
                        self.table.addCard(card);
                        self.simulateIncomingDealCardsMessage(cards: [card]);
                        // let deck: TableDeck = TableDeck();
                        // if let card: TableCard = deck.takeCard(card) {
                        //     self.table.addCard(card);
                        // }
                    }
                }
*/
            }
        }
        .onAppear {
            self.table.addCards([
                TableCard("1RHO")!, TableCard("2RHO")!, TableCard("3RHO")!, TableCard("1PSO")!,
                TableCard("1GSD")!, TableCard("2GSD")!, TableCard("3GSD")!, TableCard("2PSO")!,
                TableCard("1PQT")!, TableCard("2PQT")!, TableCard("3PQT")!, TableCard("3PSO")!,
                TableCard("1GSO")!, TableCard("2GSO")!
            ]);
        }
        .navigationTitle("Logicard Debug View")
        .navigationBarTitleDisplayMode(.inline)
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
            HStack(spacing: spacing) {
                Control(label: "Clear") { self.table.removeCards() }
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

    private struct TextBoxWithButton: View {
        @State var callback: (String) -> Void;
        @State private var inputText: String = "1GSQ"
        public var body: some View {
            HStack(spacing: 20) {
                TextField("Card", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button("Submit") { callback(inputText) }
                    .buttonStyle(.borderedProminent)
            }.padding()
        }
    }

    private static func toCards(_ cardcodes: String) -> [TableCard] {
        var cards: [TableCard] = [];
        for cardcode in cardcodes.split() {
            if let card: TableCard = TableCard(cardcode) {
                cards.add(card);
            }
        }
        return cards;
    }

    private func receiveDealCardsMessage(_ message: GameCenter.DealCardsMessage) {
        self.table.addCards(message.cards);
    }

    private func receiveMessage(_ message: Data?) {
        // if let message: GameCenter.DealCardsMessage = message as? GameCenter.DealCardsMessage {
        if let message: GameCenter.DealCardsMessage = GameCenter.DealCardsMessage(message!) {
            self.receiveDealCardsMessage(message);
        }
    }

    private func simulateIncomingDealCardsMessage(_ cards: [TableCard]) {
        let message: GameCenter.DealCardsMessage = GameCenter.DealCardsMessage(player: "A", cards: cards);
        let data: Data? = message.serialize();
        self.receiveMessage(data);
    }
}
