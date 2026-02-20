import Foundation

public extension MultiPlayer {

    public class PingMessage: Message {
        public let type: MessageType;
        public let from: String;
        public let id: String;
        public init(id: String = ID.generate) {
            self.type = .ping;
            self.from = "";
            self.id = id;
        }
    }
}
