import SwiftUI

public struct CardViewDebug: View {

    @ObservedObject var settings: Settings;
    @StateObject var table: Table;

    public init(settings: Settings) {
        self.settings = settings
        self._table = StateObject(wrappedValue: Table(settings: settings))
    }

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            CardGridView(
                table: table,
                settings: settings,
                initialEffect: Defaults.Effects.initialEffect
            )
            CardControls(table: table)
            TextBoxWithButton(label: "DEAL") { value in
                let cards: [TableCard] = CardViewDebug.toCards(value);
                self.simulateIncomingNewGameMessage(cards);
            }
            TextBoxWithButton(label: "SET!", inputText: "1GSD 2GSD 3GSD") { value in
                let cards: [TableCard] = CardViewDebug.toCards(value);
                self.simulateIncomingFoundSetMessage(cards);
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
                Control(label: "Fade")   { self.table.cards.materialize(responsivity: 0.9, elasticity: 0.1, delay: DelayBy(0...2)) }
                Control(label: "Shake")  { self.table.cards.shake() }
                Control(label: "Move")   { self.move() }.disabled(!self.moveEnabled)
            }.padding(.top, margint)
            HStack(spacing: spacing) {
                Control(label: "Clear") { self.table.removeCards() }
                Control(label: "Fade LO")   { self.table.cards.materialize(responsivity: 0.9, elasticity: 0.1) }
                Control(label: "Fade HI")   { self.table.cards.materialize(responsivity: 0.9, elasticity: 0.9) }
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
        var label: String;
        @State var callback: (String) -> Void;
        @State var inputText: String = "1GSQ"
        public var body: some View {
            HStack(spacing: 20) {
                TextField("Card", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button(label) { callback(inputText) }
                    .buttonStyle(.borderedProminent)
            }.padding()
        }
    }

    private static func toCards(_ cardcodes: String) -> [TableCard] {
        var cards: [TableCard] = [];
        for cardcode in cardcodes.split(delimiters: " ,./") {
            if let card: TableCard = TableCard(cardcode) {
                cards.add(card);
            }
        }
        return cards;
    }

    private func handleNewGameMessage(_ message: GameCenter.NewGameMessage) {
        let cards: [TableCard] = message.cards;
        self.table.addCards(cards);
    }

    private func handleFoundSetMessage(_ message: GameCenter.FoundSetMessage) {

        let cards: [TableCard] = message.cards;

        guard cards.isSet() else {
            return;
        }

        let tablecards: [TableCard] = self.table.cards.find(cards);

        guard tablecards.count == 3 else {
            return;
        }

        tablecards.select();
        CardViewDebug.possibleSetSelected(table: self.table);
    }

    private func simulateIncomingNewGameMessage(_ cards: [TableCard]) {

        // Create a test message.

        let message: GameCenter.NewGameMessage = GameCenter.NewGameMessage(player: GameCenter.HttpTransport.instance.player, cards: cards);

        // Serialize the test message to a Data object.

        let data: Data? = message.serialize();

        // Use our GameCenter function to receive, decode, and dispatch the message.

        // GameCenter.handleMessage(data, newGame: handleNewGameMessage);
        if let msg = GameCenter.NewGameMessage(data) {
            GameCenter.dispatch(message: msg, newGame: handleNewGameMessage)
        }
    }

    private func simulateIncomingFoundSetMessage(_ cards: [TableCard]) {

        // Create a test message.

        let message: GameCenter.FoundSetMessage = GameCenter.FoundSetMessage(player: GameCenter.HttpTransport.instance.player, cards: cards);

        // Serialize the test message to a Data object.

        let data: Data? = message.serialize();

        // Use our GameCenter function to receive, decode, and dispatch the message.

        // GameCenter.handleMessage(data, foundSet: handleFoundSetMessage);
        if let msg = GameCenter.FoundSetMessage(data) {
            GameCenter.dispatch(message: msg, foundSet: handleFoundSetMessage)
        }
    }

    public static func possibleSetSelected(table: Table) {
        table.possibleSetSelected(
            //
            // The delay argument to cardTouched is the amount of time (seconds)
            // to let the selected SET show as selected BEFORE we start blinking;
            // the delay within the blink callback is the amount of time to let
            // the selected SET show as selected AFTER the blinking is done and
            // BEFORE we replace them with new cards (via resolve).
            //
            delay: Defaults.Effects.selectBeforeDelay,
            onSet: CardGridCallbacks.onSet,
            onNoSet: CardGridCallbacks.onNoSet,
            onCardsMoved: CardGridCallbacks.onCardsMoved
        )
    }
}
