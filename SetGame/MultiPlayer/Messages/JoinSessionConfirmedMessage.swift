import Foundation

public extension MultiPlayer {

    public struct JoinSessionConfirmedMessage: Message {
        public let type: MessageType;
        public let sender: String;
        public let recipient: String;
        public let session: String;
        public let host: String;
        public let players: [String];
        public init(session: String, host: String, players: [String]) {
            self.type = .joinSessionConfirmed;
            self.sender = "";
            self.recipient = "";
            self.session = session;
            self.host = host;
            self.players = players;
        }
    }
}
