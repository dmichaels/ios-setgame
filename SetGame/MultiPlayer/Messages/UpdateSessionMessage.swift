import Foundation

public extension MultiPlayer {

    public struct UpdateSessionMessage: Message {
        public let type: MessageType;
        public let sender: String;
        public let host: String;
        public let players: [String];
        public init(host: String, players: [String]) {
            self.type = .updateSession;
            self.sender = "";
            self.host = host;
            self.players = players;
        }
    }
}
