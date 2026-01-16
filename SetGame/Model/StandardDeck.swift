import SwiftUI

class StandardDeck : Deck<Card> {

    static let instance       : StandardDeck = StandardDeck();
    static let instanceSimple : StandardDeck = StandardDeck(simple: true);
    static let size           : Int          = instance.count;
}
