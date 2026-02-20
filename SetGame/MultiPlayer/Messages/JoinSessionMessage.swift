import Foundation

public extension MultiPlayer {

    public struct JoinSessionMessage: Message {
        public let type: MessageType;
        public let from: String;
        public let player: String;
        public init(player: String) {
            self.type = .joinSession;
            self.from = "";
            self.player = player;
        }
    }
}
