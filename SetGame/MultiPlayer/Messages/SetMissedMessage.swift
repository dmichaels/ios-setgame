import Foundation

public extension MultiPlayer {

    public struct SetMissedMessage: Message {
        public  let type: MessageType;
        public  let player: String;
        private let codes: [String];
        public  var cards: [TableCard] { MessageConversion.toCards(self.codes) }
        public init(player: String, cards: [Card]) {
            self.type      = .setMissed;
            self.player    = player;
            self.codes = cards.map { $0.code };
        }
    }
}
