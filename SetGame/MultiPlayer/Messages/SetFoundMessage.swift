import Foundation

public extension MultiPlayer {

    public struct SetFoundMessage: Message {
        public let type: MessageType;
        //
        // For SetFoundMessage the player is the player who found the set.
        //
        public  let player: String;
        private let codes: [String];
        public  var cards: [TableCard] { MessageConversion.toCards(self.codes) }
        public init(player: String, cards: [Card]) {
            self.type      = .setFound;
            self.player    = player;
            self.codes = cards.map { $0.code };
        }
    }
}
