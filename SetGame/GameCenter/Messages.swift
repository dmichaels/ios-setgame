import SwiftUI

public enum GameCenter {}

public extension GameCenter {

    public enum MessageType: String, Codable {
        case playerReady
        case dealCards
        case foundSet
    }

    public protocol Message: Codable {
        var type: MessageType { get }
        var player: String { get }
        init?(_ data: Data?)
        func serialize() -> Data?
    }

    private struct MessageEnvelope: Decodable {
        let type: GameCenter.MessageType
    }


    public protocol MessageHandler: AnyObject {
        func handle(message: GameCenter.PlayerReadyMessage);
        func handle(message: GameCenter.DealCardsMessage);
        func handle(message: GameCenter.FoundSetMessage);
    }

    public protocol MessageSender: AnyObject {
        func send(message: GameCenter.PlayerReadyMessage);
        func send(message: GameCenter.DealCardsMessage);
        func send(message: GameCenter.FoundSetMessage);
    }

    public struct PlayerReadyMessage: Message {

        public let type: MessageType;
        public let player: String

        public init?(_ data: Data?) {
            self.init(data, as: GameCenter.PlayerReadyMessage.self);
        }

        public init(player: String, cards: [Card]) {
            self.type   = .playerReady;
            self.player = player;
        }
    }

    public struct DealCardsMessage: Message {

        public  let type: MessageType;
        public  let player: String;
        private let cardcodes: [String];

        public init?(_ data: Data?) {
            self.init(data, as: GameCenter.DealCardsMessage.self);
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
            self.init(data, as: GameCenter.FoundSetMessage.self);
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

    public static func dispatch(_ messages: [GameCenter.Message]?,
                                  playerReady: ((GameCenter.PlayerReadyMessage) -> Void)? = nil,
                                  dealCards: ((GameCenter.DealCardsMessage) -> Void)? = nil,
                                  foundSet: ((GameCenter.FoundSetMessage) -> Void)? = nil) {
        if let messages: [GameCenter.Message] = messages {
            for message in messages {
                GameCenter.dispatch(message,
                                    playerReady: playerReady,
                                    dealCards: dealCards,
                                    foundSet: foundSet);
            }
        }
    }

    public static func dispatch(_ message: GameCenter.Message?,
                                  playerReady: ((GameCenter.PlayerReadyMessage) -> Void)? = nil,
                                  dealCards: ((GameCenter.DealCardsMessage) -> Void)? = nil,
                                  foundSet: ((GameCenter.FoundSetMessage) -> Void)? = nil) {
        if let message: GameCenter.Message = message {
            switch message {
                case let message as PlayerReadyMessage: playerReady?(message);
                case let message as DealCardsMessage: dealCards?(message);
                case let message as FoundSetMessage: foundSet?(message);
                default: break;
            }
        }
    }

    private static func toMessage(data: Data?) -> GameCenter.Message? {
        if let data = data, let envelope = GameCenter.fromJson(data, GameCenter.MessageEnvelope.self) {
            switch envelope.type {
                case .playerReady:
                    if let message: GameCenter.PlayerReadyMessage = GameCenter.PlayerReadyMessage(data) {
                        return message;
                    }
                case .dealCards:
                    if let message: GameCenter.DealCardsMessage = GameCenter.DealCardsMessage(data) {
                        return message;
                    }
                case .foundSet:
                    if let message: GameCenter.FoundSetMessage = GameCenter.FoundSetMessage(data) {
                        return message;
                    }
            }
        }
        return nil;
    }

    public static func toMessages(data: Data?) -> [GameCenter.Message]? {
        var messages: [GameCenter.Message] = [];
        if let array: [Any] = GameCenter.fromJsonToArray(data) {
            for json: Any in array {
                if let json: Data = GameCenter.fromJsonToData(json) {
                    if let message: GameCenter.Message = GameCenter.toMessage(data: json) {
                        messages.append(message);
                    }
                }
            }
        }
        else if let object: Data = GameCenter.fromJsonToData(data) {
            if let json: Data = GameCenter.fromJsonToData(object) {
                if let message: GameCenter.Message = GameCenter.toMessage(data: json) {
                    return [message];
                }
            }
        }
        else {
            return nil;
        }
        return messages;
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

    private static func toJson(_ data: GameCenter.Message) -> Data? {
        do {
            return try JSONEncoder().encode(data);
        }
        catch {
            return nil;
        }
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

public extension GameCenter.Message {

    public init?<T: Decodable>(_ data: Data?, as type: T.Type) {
        guard let decoded = GameCenter.fromJson(data, type) as? Self else { return nil }
        self = decoded;
    }

    public func serialize() -> Data? {
        return GameCenter.toJson(self)
    }
}
