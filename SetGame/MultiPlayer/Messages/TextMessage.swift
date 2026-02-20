import Foundation

public extension MultiPlayer {

    public struct TextMessage: Message {
        public let type: MessageType;
        public let from: String;
        public let text: String;
        public init(text: String) {
            self.type = .text;
            self.from = "";
            self.text = text;
        }
    }
}
