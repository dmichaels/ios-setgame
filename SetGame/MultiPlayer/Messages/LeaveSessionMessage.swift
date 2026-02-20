import Foundation

public extension MultiPlayer {

    public struct LeaveSessionMessage: Message {
        public let type: MessageType;
        public let from: String;
        public let player: String;
        public init(player: String) {
            self.type = .leaveSession;
            self.from = "";
            self.player = player;
        }
    }
}
