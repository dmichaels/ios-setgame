public class TableDeck: Deck<TableCard> {
    static public let instance       : TableDeck = TableDeck();
    static public let instanceSimple : TableDeck = TableDeck(simple: true);
}
