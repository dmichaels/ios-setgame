import Foundation

public extension MultiPlayer {

    public struct RequestHostSessionMessage: Message {
        public let type: MessageType;
        public let sender: String;
        public let recipient: String;
        public let player: String;
        public init(player: String) {
            self.type = .requestHostSession;
            self.sender = "";
            self.recipient = "";
            self.player = player;
        }
    }
}
