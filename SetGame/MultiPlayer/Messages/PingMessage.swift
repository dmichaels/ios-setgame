import Foundation

public extension MultiPlayer {

    public class PingMessage: Message {
        public let type: MessageType;
        public let id: String = ID().value;
        public init() {
            self.type = .ping;
        }
    }
}
