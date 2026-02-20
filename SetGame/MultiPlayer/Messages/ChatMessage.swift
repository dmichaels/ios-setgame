import Foundation

public extension MultiPlayer {

    public struct ChatMessage: Message {
        public let type: MessageType;
        public let from: String;
        public let text: String;
        public init(_ text: String) {
            self.type = .chat;
            self.from = "";
            self.text = text;
        }
    }
}
