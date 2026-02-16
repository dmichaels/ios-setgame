import Foundation

public extension MultiPlayer {

    public struct JoinSessionMessage: Message {
        public let id: UUID = UUID();
        public let type: MessageType;
        public let player: String;
        public init(player: String) {
            self.type = .joinSession;
            self.player = player;
        }
    }
}
