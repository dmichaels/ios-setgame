class StandardDeck : Deck<Card> {

    static let instance       : StandardDeck = StandardDeck();
    static let instanceSimple : StandardDeck = StandardDeck(simple: true);
    static let size           : Int          = instance.count;

    private init() {
        super.init(readonly: true);
    }

    private init(simple: Bool) {
        super.init(simple: simple, readonly: true);
    }

    /// Returns (without removal) a random card from a standard deck.
    ///
    func randomCard() -> Card {
        return Self.instance.cards[Int.random(in: 0..<Self.instance.cards.count)];
    }

    /// Returns (without removal) a random SET from a standard deck.
    ///
    func randomSet() -> [Card] {
        let deck = StandardDeck();
        let a = deck.takeRandomCard()!;
        let b = deck.takeRandomCard()!;
        let c = Card.matchingSetValue(a, b);
        return [a, b, c];
    }
}
