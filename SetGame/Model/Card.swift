/// Card represents a single SET card from a SET Game® deck.
///
public class Card {

    public private(set) var color   : CardColor;
    public private(set) var shape   : CardShape;
    public private(set) var filling : CardFilling;
    public private(set) var number  : CardNumber;

    /// Creates a card from a String representation of the card or nil if not unparsable.
    /// Required so we (CardList) can create a generic Card or subclass thereof.
    ///
    required convenience init?(_ value: String) {
        if let card = Card.from(value) {
            self.init(card);
        }
        else {
            return nil;
        }
    }

    /// Creates a card from a Substring representation of the card or nil if not unparsable.
    /// Required so we (CardList) can create a generic Card or subclass thereof.
    ///
    required convenience init?(_ value: Substring) {
        self.init(String(value));
    }

    /// Creates random card.
    ///
    required convenience init() {
         self.init(color: .random, shape: .random, filling: .random, number: .random);
    }

    /// Creates Card from given specific attributes (designated init).
    ///
    required init(color: CardColor, shape: CardShape, filling: CardFilling, number: CardNumber) {
        self.color   = color;
        self.shape   = shape;
        self.filling = filling;
        self.number  = number;
    }

    /// Creates card from given Card; i.e. copy constructor (designated init).
    ///
    required init(_ card : Card) {
        self.color   = card.color;
        self.shape   = card.shape;
        self.filling = card.filling;
        self.number  = card.number;
    }

    /// Returns true iff the given two cards form a SET with this card, otherwise false.
    ///
    func formsSetWith(_ b: Card, _ c: Card) -> Bool {
        return Card.isSet(self, b, c);
    }

    /// Returns the new unique card which completes the SET for the given two cards.
    ///
    static func matchingSetValue(_ b: Card, _ c: Card) -> Card {
        let color   : CardColor   = .matchingSetValue(b.color,   c.color);
        let shape   : CardShape   = .matchingSetValue(b.shape,   c.shape);
        let filling : CardFilling = .matchingSetValue(b.filling, c.filling);
        let number  : CardNumber  = .matchingSetValue(b.number,  c.number);
        return Card(color: color, shape: shape, filling: filling, number: number);
    }

    /// Returns true iff the given cards form a SET; note this is static.
    /// Maybe could reside in CardList; but will keep the rules of SET
    /// logic in here; and in the attribute classes, i.e. formsSetWith,
    /// matchingSetValue in CardColor, CardShape, CardFilling, CardNumber.
    ///
    static func isSet(_ cards: Card...) -> Bool {
        if (cards.count != 3) { return false; }
        return cards[0].color   .formsSetWith(cards[1].color,   cards[2].color)
            && cards[0].shape   .formsSetWith(cards[1].shape,   cards[2].shape)
            && cards[0].filling .formsSetWith(cards[1].filling, cards[2].filling)
            && cards[0].number  .formsSetWith(cards[1].number,  cards[2].number);
    }

    /// Returns the unique 'codename' for this card.
    /// This can be used as a short name for this card and could conveniently
    /// be used to identify an (image) asset for the card.
    ///
    var codename: String {
        return color.codename + shape.codename + filling.codename + number.codename;
    }

    /// Parses a string representation of a SET card and returns its Card instance, or nil
    /// if unparsable. This representation may be a dash-separated list of case-insensitive
    /// attribute names, e.g. "Red-Oval-Stripped-Two", where the order of attribute names
    /// does NOT matter; or the representation may be a simple sequence case-insensitive
    /// characters (unique across all attributes), where the order of the characters
    /// does NOT matter, as defined below, so we can represent a card
    /// like "ROS2" (meaning: Red-Oval-Solid-Two):
    ///
    /// Color:   G = Green
    ///          P = Purple
    ///          R = Red
    ///
    /// Shape:   D = Diamond
    ///          O = Oval
    ///          Q = Squiggle
    ///
    /// Filling: H = Hollow
    ///          S = Solid
    ///          T = Stripped
    ///
    /// Number:  1 = One
    ///          2 = Two
    ///          3 = Three
    ///
    /// Cards represented with these codes will also be used for the Card 'codename'
    /// which will be used to identify the name of the image asset to use in the UI;
    /// attributes being in the above order, i.e. color, shape, filling, number.
    ///
    class func from(_ value: String) -> Card? {
        var value = value.filter{ !$0.isWhitespace }.lowercased();
        if (value.count == 4) {
            value = String(value[0]) + "-" +
                    String(value[1]) + "-" +
                    String(value[2]) + "-" +
                    String(value[3]) + "-";
        }
        let components = value.split(){($0 == "-") || ($0 == ":")};
        if (components.count == 4) {
            var components = components.map { String($0) };
            if let (color, index) = CardColor.from(components)  {
                components.remove(at: index);
                if let (shape, index) = CardShape.from(components)  {
                    components.remove(at: index);
                    if let (filling, index) = CardFilling.from(components)  {
                        components.remove(at: index);
                        if let (number, _) = CardNumber.from(components)  {
                            return Card(color: color, shape: shape, filling: filling, number: number);
                        }
                    }
                }
            }
        }
        return nil;
    }

    /// Returns a string representation of this card.
    ///
    func toString(_ verbose : Bool = false) -> String {
        return verbose ? "\(color)-\(shape)-\(filling)-\(number)"
                       : "\(codename)"
    }

    /// For debugging.
    ///
    // var uid: String { String(ObjectIdentifier(self).hashValue, radix: 16).uppercased() }
    var uid: String { String(format: "%X", ObjectIdentifier(self).hashValue) }
    var sid: String { String(format: "%6X", ObjectIdentifier(self).hashValue & 0xFFFFFF) }
    var vid: String { String(format: "%4X", ObjectIdentifier(self).hashValue & 0xFFFF) }
}

/// Card extensions to conform to sundry protocols.
///
extension Card: Identifiable, Equatable, Comparable, CustomStringConvertible {

    public var id: String { self.codename; }

    public static func == (lhs: Card, rhs: Card) -> Bool {
        return (lhs.color   == rhs.color)   &&
               (lhs.shape   == rhs.shape)   &&
               (lhs.filling == rhs.filling) &&
               (lhs.number  == rhs.number);
    }

    public static func < (lhs: Card, rhs: Card) -> Bool {
        if (lhs.number.rawValue < rhs.number.rawValue) {
            return true;
        }
        else if (lhs.number.rawValue > rhs.number.rawValue) {
            return false;
        }
        else if (lhs.color.rawValue < rhs.color.rawValue) {
            return true;
        }
        else if (lhs.color.rawValue > rhs.color.rawValue) {
            return false;
        }
        else if (lhs.shape.rawValue < rhs.shape.rawValue) {
            return true;
        }
        else if (lhs.shape.rawValue > rhs.shape.rawValue) {
            return false;
        }
        else if (lhs.filling.rawValue < rhs.filling.rawValue) {
            return true;
        }
        else if (lhs.filling.rawValue > rhs.filling.rawValue) {
            return false;
        }
        else {
            return false;
        }
    }

    public var description: String {
        return self.toString();
    }
}
