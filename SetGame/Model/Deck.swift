/// Deck represents a deck of SET Game® card deck.
/// Can be created with a subclass of Card if you like.
///
public class Deck<T: Card> {

    public private(set) var cards: [T];

    /// Creates a new shuffled SET Game® card deck.
    /// - Can be a "simple" deck in which case the only filling is solid; this,
    ///   surprisingly, is actually the default for the official SET Game® app deck.
    ///
    public init(simple: Bool = false, shuffle: Bool = false) {
        self.cards = Deck.createCards(simple: simple, shuffle: shuffle);
    }

    public var count: Int {
        return self.cards.count;
    }

    public func takeCard(_ card: T) -> T? {
        if (self.cards.contains(card)) {
            self.cards.remove(card);
            return card;
        }
        return nil;
    }

    public func takeCards(_ cards: [T], strict: Bool = false) -> [T]? {
        return self.cards.takeCards(cards, strict: strict);
    }

    public func takeRandomCards(_ n: Int, plantSet: Bool = false, existingCards: [T] = [], rng: RNG?) -> [T] {
        return self.cards.takeRandomCards(n, plantSet: plantSet, existingCards: existingCards, rng: rng);
    }

    private static func createCards(simple: Bool = false, shuffle: Bool = true) -> [T] {
        var cards: [T] = [];
        let fillings: [CardFilling] = simple ? [CardFilling.Solid]: CardFilling.allCases;
        for color in CardColor.allCases {
            for shape in CardShape.allCases {
                for filling in fillings {
                    for number in CardNumber.allCases {
                        cards.add(T(color: color, shape: shape, filling: filling, number: number));
                    }
                }
            }
        }
        if (shuffle) {
            cards.shuffle();
        }
        return cards;
    }
}
