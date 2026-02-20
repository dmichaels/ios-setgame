import Foundation

public extension MultiPlayer {

    public struct JoinSessionConfirmedMessage: Message {
        public let type: MessageType;
        public let from: String;
        public let session: String;
        public let host: String;
        public let players: [String];
        public init(session: String, host: String, players: [String]) {
            self.type = .joinSessionConfirmed;
            self.from = "";
            self.session = session;
            self.host = host;
            self.players = players;
        }
    }
}
