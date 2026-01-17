/// Deck represents a deck of SET Game® card deck.
/// Can be created with a subclass of Card if you like.
///
public class Deck<T : Card> {

    public private(set) var cards    : [T];
    public              let readonly : Bool;
    public              let simple   : Bool;

    /// Creates a new shuffled SET Game® card deck.
    /// - Can be a "simple" deck in which case the only filling is solid; this,
    ///   surprisingly, is actually the default for the official SET Game® app deck.
    /// - Can contain just a random subset of cards if the given ncards is greater than 1;
    ///   the default card count is, of course, 3 * 3 * 3 * 3 = 81.
    /// - Can be readonly (for the deck here) in which case no cards will be removed.
    ///
    init(simple: Bool = false, ncards: Int = 0, readonly: Bool = false) {
        self.readonly = readonly;
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
        if ((ncards > 0) && (ncards < self.cards.count)) {
            let nremove: Int = self.cards.count - ncards;
            for _ in 0..<nremove {
                _ = self.cards.takeRandomCard();
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
        return self.readonly ? [T]() : self.cards.takeRandomCards(n, plantSet: plantSet, existingCards: existingCards);
    }
}
