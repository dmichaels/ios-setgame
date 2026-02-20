import Foundation

public extension MultiPlayer {

    public struct SetConfirmedMessage: Message {
        public  let type: MessageType;
        public let from: String;
        public  let player: String;
        private let codes: [String];
        public  var cards: [TableCard] { MessageConversion.toCards(self.codes) }
        public init(player: String, cards: [Card]) {
            self.type = .setConfirmed;
            self.from = "";
            self.player = player;
            self.codes = cards.map { $0.code };
        }
    }
}
