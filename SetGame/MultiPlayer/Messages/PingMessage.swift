import Foundation

public extension MultiPlayer {

    public class PingMessage: Message {
        public let type: MessageType;
        public let sender: String;
        public let id: String;
        public init(id: String = ID.generate) {
            self.type = .ping;
            self.sender = "";
            self.id = id;
        }
    }
}
