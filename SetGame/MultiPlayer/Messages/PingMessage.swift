public extension MultiPlayer {

    public class PingMessage: Message {
        public let type: MessageType;
        public init() {
            self.type = .ping;
        }
    }
}
