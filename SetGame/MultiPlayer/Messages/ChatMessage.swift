import Foundation

public extension MultiPlayer {

    public struct ChatMessage: Message {
        public let type: MessageType;
        public let from: String;
        public let recipient: String;
        public let text: String;
        public init(recipient: String, text: String) {
            self.type = .chat;
            self.from = "";
            self.recipient = recipient;
            self.text = text;
        }
    }
}
