import SwiftUI

public enum GameCenter {}

public extension GameCenter
{
    public enum MessageType: String, Codable {
        case playerReady;
        case dealCards;
        case foundSet;
    }

    public protocol Message: Codable {
        var type: MessageType { get };
        var player: String { get };
        init?(_ data: Data?);
        func serialize() -> Data?;
    }

    public protocol MessageHandler: AnyObject {
        func handle(message: PlayerReadyMessage);
        func handle(message: DealCardsMessage);
        func handle(message: FoundSetMessage);
    }

    public protocol MessageSender: AnyObject {
        func send(message: PlayerReadyMessage);
        func send(message: DealCardsMessage);
        func send(message: FoundSetMessage);
    }
}

public extension GameCenter.Message
{
    public init?(_ data: Data?, internal: Bool) {
        guard let message = GameCenter.toMessage(data: data) as? Self else { return nil }
        self = message;
    }

    // public init?<T: Decodable>(_ data: Data?, as type: T.Type) {
    //     guard let message = GameCenter.fromJson(data, type) as? Self else { return nil }
    //     self = message;
    // }

    public func serialize() -> Data? {
        do { return try JSONEncoder().encode(self); } catch { return nil; }
    }
}

public extension GameCenter
{
    public struct PlayerReadyMessage: Message {

        public let type: MessageType;
        public let player: String

        public init?(_ data: Data?) {
            // self.init(data, as: PlayerReadyMessage.self);
            self.init(data, internal: true);
        }

        public init(player: String) {
            self.type   = .playerReady;
            self.player = player;
        }
    }

    public struct DealCardsMessage: Message {

        public  let type: MessageType;
        public  let player: String;
        private let cardcodes: [String];

        public init?(_ data: Data?) {
            // self.init(data, as: DealCardsMessage.self);
            self.init(data, internal: true);
        }

        public init(player: String, cards: [Card]) {
            self.type      = .dealCards;
            self.player    = player;
            self.cardcodes = cards.map { $0.code };
        }

        public var cards: [TableCard] {
            return GameCenter.toCards(self.cardcodes).map { TableCard($0) }
        }
    }

    public struct FoundSetMessage: Message {

        public let type: MessageType;
        public let player: String;
        public let cardcodes: [String];

        public init?(_ data: Data?) {
            // self.init(data, as: FoundSetMessage.self);
            self.init(data, internal: true);
        }

        public init(player: String, cards: [Card]) {
            self.type      = .foundSet;
            self.player    = player;
            self.cardcodes = cards.map { $0.code };
        }

        public var cards: [TableCard] {
            return GameCenter.toCards(self.cardcodes).map { TableCard($0) }
        }
    }
}

public extension GameCenter
{
    public static func toMessage(data: Data?) -> Message? {
        struct MessageEnvelope: Decodable { let type: MessageType; }
        if let data: Data = data,
           let envelope: MessageEnvelope = GameCenter.fromJson(data, MessageEnvelope.self) {
            switch envelope.type {
                case .playerReady:
                    if let message: PlayerReadyMessage = GameCenter.fromJson(data, PlayerReadyMessage.self) {
                        return message;
                    }
                case .dealCards:
                    if let message: DealCardsMessage = GameCenter.fromJson(data, DealCardsMessage.self) {
                        return message;
                    }
                case .foundSet:
                    if let message: FoundSetMessage = GameCenter.fromJson(data, FoundSetMessage.self) {
                        return message;
                    }
            }
        }
        return nil;
    }

    public static func toMessages(data: Data?) -> [GameCenter.Message]? {
        guard let data = data else { return nil }
        guard let rawArray: [[String: Any]] = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return nil
        }
        var messages: [GameCenter.Message] = []
        messages.reserveCapacity(rawArray.count)
        let decoder: JSONDecoder = JSONDecoder()
        for object: [String: Any] in rawArray {
            // Convert one object → Data
            guard JSONSerialization.isValidJSONObject(object),
                let objectData = try? JSONSerialization.data(withJSONObject: object)
            else { continue }

            // Convert Data → Message
            if let message: Message = toMessage(data: objectData) {
                messages.append(message)
            }
        }
        return messages
    }

    public static func old_toMessages(data: Data?) -> [Message]? {
        if let array: [Any] = GameCenter.fromJsonToArray(data) {
            var messages: [Message] = [];
            for json: Any in array {
                if let json: Data = GameCenter.fromJsonToData(json) {
                    if let message: Message = GameCenter.toMessage(data: json) {
                        messages.append(message);
                    }
                }
            }
            return messages;
        }
        else if let object: Data = GameCenter.fromJsonToData(data) {
            if let json: Data = GameCenter.fromJsonToData(object) {
                if let message: Message = GameCenter.toMessage(data: json) {
                    return [message];
                }
            }
        }
        return nil;
    }

    private static func fromJson<T: Decodable>(_ data: Data?, _ type: T.Type) -> T? {
        if let data: Data = data {
            do { return try JSONDecoder().decode(type, from: data); } catch {}
        }
        return nil;
    }

    private static func fromJsonToArray(_ data: Data?) -> [Any]? {
        if let data: Data = data {
            if let array: [Any] = try? JSONSerialization.jsonObject(with: data) as? [Any] {
                return array;
            }
        }
        return nil;
    }

    private static func fromJsonToData(_ data: Any?) -> Data? {
        if let data: Any = data {
            if let object: Data = try? JSONSerialization.data(withJSONObject: data) {
                return object;
            }
        }
        return nil;
    }

    private static func toCards(_ codes: [String]) -> [Card] {
        var cards: [Card] = [];
        for code in codes {
            if let card: Card = Card(code) {
                cards.append(card);
            }
        }
        return cards;
    }
}

public extension GameCenter
{
    public static func dispatch(data: Data?,
                                playerReady: ((PlayerReadyMessage) -> Void)? = nil,
                                dealCards: ((DealCardsMessage) -> Void)? = nil,
                                foundSet: ((FoundSetMessage) -> Void)? = nil) {
        if let messages: [Message] = GameCenter.toMessages(data: data) {
            GameCenter.dispatch(messages: messages,
                                playerReady: playerReady,
                                dealCards: dealCards,
                                foundSet: foundSet);
        }
    }

    public static func dispatch(message: Message?,
                                playerReady: ((PlayerReadyMessage) -> Void)? = nil,
                                dealCards: ((DealCardsMessage) -> Void)? = nil,
                                foundSet: ((FoundSetMessage) -> Void)? = nil) {
        if let message: Message = message {
            switch message {
                case let message as PlayerReadyMessage: playerReady?(message);
                case let message as DealCardsMessage: dealCards?(message);
                case let message as FoundSetMessage: foundSet?(message);
                default: break;
            }
        }
    }

    public static func dispatch(messages: [Message]?,
                                playerReady: ((PlayerReadyMessage) -> Void)? = nil,
                                dealCards: ((DealCardsMessage) -> Void)? = nil,
                                foundSet: ((FoundSetMessage) -> Void)? = nil) {
        if let messages: [Message] = messages {
            for message in messages {
                GameCenter.dispatch(message: message,
                                    playerReady: playerReady,
                                    dealCards: dealCards,
                                    foundSet: foundSet);
            }
        }
    }

    // These dispatch calls mey look weird, the three handler.handle references in a row,
    // but Swift typing works it magic and sorts it; so that for example, handler.handle for
    // dealCards handler.handle references MessageHandler.handle(message: DealCardsMessage).
    //
    public static func dispatch(data: Data?, _ handler: MessageHandler) {
        GameCenter.dispatch(data: data,
                            playerReady: handler.handle,
                            dealCards: handler.handle,
                            foundSet: handler.handle);
    }

    public static func dispatch(message: Message?, _ handler: MessageHandler) {
        GameCenter.dispatch(message: message,
                            playerReady: handler.handle,
                            dealCards: handler.handle,
                            foundSet: handler.handle);
    }

    public static func dispatch(messages: [Message]?, _ handler: MessageHandler) {
        GameCenter.dispatch(messages: messages,
                            playerReady: handler.handle,
                            dealCards: handler.handle,
                            foundSet: handler.handle);
    }
}
