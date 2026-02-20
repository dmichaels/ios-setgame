import Foundation

public extension MultiPlayer {

    public class PingAcknowledgeMessage: Message {
        public let type: MessageType;
        public let sender: String;
        public let id: String;
        public init(id: String) {
            self.type = .pingAcknowledge;
            self.sender = "";
            self.id = id;
        }
    }
}
