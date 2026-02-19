import Foundation

public extension MultiPlayer {

    public class PingMessage: Message {
        public let type: MessageType;
        public let from: String;
        public let id: String;
        public init(from: String, id: String = ID().value) {
            self.type = .ping;
            self.from = from;
            self.id = id;
        }
    }
}
