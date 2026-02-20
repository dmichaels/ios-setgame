import Foundation

public extension MultiPlayer {

    public struct NewGameMessage: Message {
        public let type: MessageType;
        public let sender: String;
        public let seed: Int;
        public init(seed: Int? = nil) {
            self.type  = .newGame;
            self.sender = "";
            self.seed  = seed ?? Int.random(in: 1...Int.max);
        }
    }
}
