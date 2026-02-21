import Foundation

public extension MultiPlayer {

    public struct LeaveSessionMessage: Message {
        public let type: MessageType;
        public let sender: String;
        public let recipient: String;
        public let player: String;
        public init(player: String) {
            self.type = .leaveSession;
            self.sender = "";
            self.recipient = "";
            self.player = player;
        }
    }
}
