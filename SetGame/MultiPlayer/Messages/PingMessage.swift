import Foundation

public extension MultiPlayer {

    public class PingMessage: Message {
        public let id: UUID = UUID();
        public let type: MessageType;
        public init() {
            self.type = .ping;
        }
    }
}
