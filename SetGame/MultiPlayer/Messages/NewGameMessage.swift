import Foundation

public extension MultiPlayer {

    public struct NewGameMessage: Message {
        public let type: MessageType;
        public let from: String;
        public let seed: Int;
        public init(seed: Int? = nil) {
            self.type  = .newGame;
            self.from = "";
            self.seed  = seed ?? Int.random(in: 1...Int.max);
        }
    }
}
