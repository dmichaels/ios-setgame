import Foundation

public extension MultiPlayer {

    public struct JoinSessionMessage: Message {
        public let type: MessageType;
        public let sender: String;
        public let player: String;
        public init(player: String) {
            self.type = .joinSession;
            self.sender = "";
            self.player = player;
        }
    }
}
