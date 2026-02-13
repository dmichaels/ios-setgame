public extension GameCenter {

    public struct JoinSessionConfirmedMessage: Message {
        public let type: MessageType;
        public let session: String;
        public let host: String;
        public init(session: String, host: String) {
            self.type = .joinSessionConfirmed;
            self.session = session;
            self.host = host;
        }
    }
}
