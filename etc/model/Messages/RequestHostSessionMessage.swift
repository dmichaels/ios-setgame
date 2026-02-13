public extension GameCenter {

    public struct RequestHostSessionMessage: Message {
        public let type: MessageType;
        public let player: String;
        public init(player: String) {
            self.type = .requestHostSession;
            self.player = player;
        }
    }
}
