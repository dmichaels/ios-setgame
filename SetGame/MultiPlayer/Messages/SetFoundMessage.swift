import Foundation

public extension MultiPlayer {

    public struct SetFoundMessage: Message {
        public  let type: MessageType;
        public  let sender: String;
        public  let recipient: String;
        //
        // For SetFoundMessage the player is the player who found the set.
        //
        public  let player: String;
        private let codes: [String];
        public  var cards: [TableCard] { MessageConversion.toCards(self.codes) }
        public init(player: String, cards: [Card]) {
            self.type = .setFound;
            self.sender = "";
            self.recipient = "";
            self.player = player;
            self.codes = cards.map { $0.code };
        }
    }
}
