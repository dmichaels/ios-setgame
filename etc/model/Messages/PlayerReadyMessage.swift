    public struct PlayerReadyMessage: Message {
        public let type: MessageType;
        public let player: String;
        public init(player: String) {
            self.type   = .playerReady;
            self.player = player;
        }
    }
