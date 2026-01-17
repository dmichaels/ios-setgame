/// Deck represents a deck of SET Game® card deck.
/// Can be created with a subclass of Card if you like.
///
public class Deck<T : Card> {

    public private(set) var cards    : [T];
    public              let simple   : Bool;

    /// Creates a new shuffled SET Game® card deck.
    /// - Can be a "simple" deck in which case the only filling is solid; this,
    ///   surprisingly, is actually the default for the official SET Game® app deck.
    ///
    init(simple: Bool = false) {
        self.cards = [T]();
        self.simple = simple;
        let fillings: [CardFilling] = simple ? [CardFilling.Solid] : CardFilling.allCases;
        for color in CardColor.allCases {
            for shape in CardShape.allCases {
                for filling in fillings {
                    for number in CardNumber.allCases {
                        self.cards.add(T(color: color, shape: shape, filling: filling, number: number));
                    }
                }
            }
        }
        self.cards.shuffle();
    }

    var count: Int {
        return self.cards.count;
    }

    /// Returns true iff the given card is in this deck.
    /// Don't fully understand why this it's necessary to have this specialized
    /// function for Card vs. T; need because we get a compiler type mismatch
    /// error when calling the T based function above with a card of type Card.
    ///
    func contains(_ card : Card) -> Bool {
        return self.cards.contains(T(card));
    }

    func takeCard(_ card : T) -> T? {
        if (self.contains(card)) {
            self.cards.remove(card);
            return card;
        }
        return nil;
    }

    func takeRandomCards(_ n : Int, plantSet: Bool = false, existingCards: [T] = []) -> [T] {
        return self.cards.takeRandomCards(n, plantSet: plantSet, existingCards: existingCards);
    }
}
