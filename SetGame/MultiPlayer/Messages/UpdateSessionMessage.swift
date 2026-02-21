import Foundation

public extension MultiPlayer {

    public struct UpdateSessionMessage: Message {
        public let type: MessageType;
        public let sender: String;
        public let recipient: String;
        public let host: String;
        public let players: [String];
        public init(host: String, players: [String]) {
            self.type = .updateSession;
            self.sender = "";
            self.recipient = "";
            self.host = host;
            self.players = players;
        }
    }
}
