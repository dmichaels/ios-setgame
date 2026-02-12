public extension GameCenter {

    public struct JoinedSessionMessage: Message {
        public let type: MessageType;
        public let session: String;
        public let host: String;
        public init(session: String, host: String) {
            self.type   = .joinedSession;
            self.session = session;
            self.host = host;
        }
    }
}
