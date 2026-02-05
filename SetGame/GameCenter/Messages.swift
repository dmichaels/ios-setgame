import Foundation

public extension GameCenter.Message
{
    public init?(_ data: Data?, internal: Bool) {
        guard let message = GameCenter.MessageConversion.toMessage(data: data) as? Self else { return nil }
        self = message;
    }
}

public extension GameCenter
{
    public struct PingMessage: Message {
        public let type: MessageType;
        public init() {
            self.type = .ping;
        }
    }

    public struct PlayerReadyMessage: Message {
        public let type: MessageType;
        public let player: String;
        public init(player: String) {
            self.type   = .playerReady;
            self.player = player;
        }
    }

    public struct NewGameMessage: Message {
        public  let type: MessageType;
        public  let seed: Int;
        public init(seed: Int? = nil) {
            self.type  = .newGame;
            self.seed  = seed ?? Int.random(in: 1...Int.max);
        }
    }

    public struct FoundSetMessage: Message {
        public  let type: MessageType;
        //
        // For FoundSetMessage the player is the player who found the set.
        //
        public  let player: String;
        private let codes: [String];
        public  var cards: [TableCard] { MessageConversion.toCards(self.codes) }
        public init(player: String, cards: [Card]) {
            self.type      = .foundSet;
            self.player    = player;
            self.codes = cards.map { $0.code };
        }
    }

    public struct ConfirmedSetMessage: Message {
        public  let type: MessageType;
        //
        // For ConfirmedSetMessage the player is the player who first found the set.
        //
        public  let player: String;
        private let codes: [String];
        private let replacementCodes: [String];
        public  var cards: [TableCard] { MessageConversion.toCards(self.codes) }
        public  var replacements: [TableCard] { MessageConversion.toCards(self.replacementCodes) }
        public init(player: String, cards: [Card], replacements: [Card]) {
            self.type      = .confirmedSet;
            self.player    = player;
            self.codes = cards.map { $0.code };
            self.replacementCodes = cards.map { $0.code };
        }
    }
}

public extension GameCenter { public struct MessageConversion
{
    public static func toMessages(data: Data?) -> [Message]? {
        if let data: Data = data,
           let array: [[String: Any]] = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            var messages: [Message] = []; messages.reserveCapacity(array.count);
            let decoder: JSONDecoder = JSONDecoder();
            for object: [String: Any] in array {
                if JSONSerialization.isValidJSONObject(object),
                   let item: Data = try? JSONSerialization.data(withJSONObject: object) {
                    if let message: Message = MessageConversion.toMessage(data: item) {
                        messages.append(message);
                    }
                 }
            }
            return messages;
        }
        return nil;
    }

    // TEMPORARY WHILE MIGRATING TO THIS ...
    public static func toMessage(data: Data?) -> Message? {
    // fileprivate static func toMessage(data: Data?) -> Message? {
    // ... END TEMPORARY WHILE MIGRATING TO THIS
        struct MessageEnvelope: Decodable { let type: MessageType; }
        if let data: Data = data,
        let envelope: MessageEnvelope = try? JSONDecoder().decode(MessageEnvelope.self, from: data) {
            switch envelope.type {
                case .ping:         return try? JSONDecoder().decode(PingMessage.self, from: data);
                case .playerReady:  return try? JSONDecoder().decode(PlayerReadyMessage.self, from: data);
                case .newGame:      return try? JSONDecoder().decode(NewGameMessage.self, from: data);
                case .foundSet:     return try? JSONDecoder().decode(FoundSetMessage.self, from: data);
                case .confirmedSet: return try? JSONDecoder().decode(ConfirmedSetMessage.self, from: data);
            }
        }
        return nil;
    }

    fileprivate static func toCards(_ codes: [String]) -> [TableCard] {
        return codes.compactMap { TableCard($0) };
    }
}}

public extension GameCenter { public struct MessageConveyance
{
    public static func dispatch(messages: [Message]?, handler: MessageHandler) {
        if let messages: [Message] = messages {
            for message: Message in messages {
                GameCenter.MessageConveyance.dispatch(message: message,
                             ping: handler.handle,
                             playerReady: handler.handle,
                             newGame: handler.handle,
                             foundSet: handler.handle,
                             confirmedSet: handler.handle);
            }
        }
    }

    // TEMPORARY WHILE MIGRATING TO THIS ...
    // private static func dispatch(message: Message?,
    public static func dispatch(message: Message?,
    // ... END TEMPORARY WHILE MIGRATING TO THIS
                                ping: ((PingMessage) -> Void)? = nil,
                                playerReady: ((PlayerReadyMessage) -> Void)? = nil,
                                newGame: ((NewGameMessage) -> Void)? = nil,
                                foundSet: ((FoundSetMessage) -> Void)? = nil,
                                confirmedSet: ((ConfirmedSetMessage) -> Void)? = nil) {
        if let message: Message = message {
            switch message {
                case let message as PingMessage: ping?(message);
                case let message as PlayerReadyMessage: playerReady?(message);
                case let message as NewGameMessage: newGame?(message);
                case let message as FoundSetMessage: foundSet?(message);
                case let message as ConfirmedSetMessage: confirmedSet?(message);
                default: break;
            }
        }
    }
}}
