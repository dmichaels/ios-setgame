public class TableDeck: Deck<TableCard> {

    private static let  instance: TableDeck = TableDeck();
    private static let  instanceSimple: TableDeck = TableDeck(simple: true);

    public static func instance(simple: Bool = false) -> TableDeck {
        return simple ? TableDeck.instanceSimple : TableDeck.instance;
    }

    /// Returns (WITHOUT removal) a random magic SET square from a full deck.
    /// N.B. Currently ONLY for the purpose of constructing a magic square.
    ///
    public static func randomMagicSquare(simple: Bool = false) -> [TableCard] {
        var magic: [Card] = TableDeck.instance(simple: simple).cards.randomNonSetCards();
        magic.append(Card.matchingSetValue(magic[0], magic[1])); // [3] from [0] and [1]
        magic.append(Card.matchingSetValue(magic[0], magic[2])); // [4] from [0] and [2]
        magic.append(Card.matchingSetValue(magic[3], magic[4])); // [5] from [3] and [4]
        magic.append(Card.matchingSetValue(magic[2], magic[5])); // [6] from [2] and [5]
        magic.append(Card.matchingSetValue(magic[1], magic[5])); // [7] from [1] and [5)
        magic.append(Card.matchingSetValue(magic[0], magic[5])); // [8] from [0] and [5]
        magic = [magic[0], magic[1], magic[3], magic[2], magic[5], magic[6], magic[4], magic[7], magic[8]];
        return magic.map { TableCard($0) };
    }
}
