import Foundation

public extension MultiPlayer {

    public struct RequestHostSessionMessage: Message {
        public let type: MessageType;
        public let from: String;
        public let player: String;
        public init(player: String) {
            self.type = .requestHostSession;
            self.from = "";
            self.player = player;
        }
    }
}
