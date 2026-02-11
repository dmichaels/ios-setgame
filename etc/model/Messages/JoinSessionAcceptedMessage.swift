    public struct JoinSessionAcceptedMessage: Message {
        public let type: MessageType;
        public let session: String;
        public init(session: String) {
            self.type   = .joinSessionAccepted;
            self.session = session;
        }
    }
