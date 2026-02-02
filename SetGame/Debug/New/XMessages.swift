import Foundation

public extension XGameCenter.Message
{
    public init?(_ data: Data?, internal: Bool) {
        guard let message = XGameCenter.MessageConversion.toMessage(data: data) as? Self else { return nil }
        self = message;
    }
}

public extension XGameCenter
{
    public struct PingMessage: Message {

        public let type: MessageType;
        public let player: String;

        public init(player: String) {
            self.type   = .ping;
            self.player = player;
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
        public  let player: String;
        private let codes: [String];
        public  var cards: [TableCard] { return MessageConversion.toCards(self.codes); }

        public init(player: String, cards: [Card]) {
            self.type      = .newGame;
            self.player    = player;
            self.codes = cards.map { $0.code };
        }
    }

    public struct FoundSetMessage: Message {

        public  let type: MessageType;
        public  let player: String;
        private let codes: [String];
        public  var cards: [TableCard] { return MessageConversion.toCards(self.codes); }

        public init(player: String, cards: [Card]) {
            self.type      = .foundSet;
            self.player    = player;
            self.codes = cards.map { $0.code };
        }
    }

    public struct ConfirmedSetMessage: Message {

        public  let type: MessageType;
        public  let player: String;
        private let codes: [String];
        private let replacementCodes: [String];
        public  var cards: [TableCard] { return MessageConversion.toCards(self.codes); }
        public  var replacements: [TableCard] { return MessageConversion.toCards(self.replacementCodes); }

        public init(player: String, cards: [Card], replacements: [Card]) {
            self.type      = .confirmedSet;
            self.player    = player;
            self.codes = cards.map { $0.code };
            self.replacementCodes = cards.map { $0.code };
        }
    }
}

public extension XGameCenter { public struct MessageConversion
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

    fileprivate static func toMessage(data: Data?) -> Message? {
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

public extension XGameCenter { public struct MessageConveyance
{
    public static func dispatch(messages: [Message]?, handler: MessageHandler) {
        if let messages: [Message] = messages {
            for message: Message in messages {
                XGameCenter.MessageConveyance.dispatch(message: message,
                             ping: handler.handle,
                             playerReady: handler.handle,
                             newGame: handler.handle,
                             foundSet: handler.handle,
                             confirmedSet: handler.handle);
            }
        }
    }

    private static func dispatch(message: Message?,
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
