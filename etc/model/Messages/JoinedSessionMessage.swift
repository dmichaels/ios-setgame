public extension GameCenter {

    public struct JoinedSessionMessage: Message {
        public let type: MessageType;
        public let session: String;
        public init(session: String) {
            self.type   = .joinedSession;
            self.session = session;
        }
    }
}
