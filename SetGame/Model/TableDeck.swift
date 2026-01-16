class TableDeck: Deck<TableCard> {
    static let instance       : TableDeck = TableDeck();
    static let instanceSimple : TableDeck = TableDeck(simple: true);
    static let size           : Int  = instance.count;
}
