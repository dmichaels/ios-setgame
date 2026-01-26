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

        public static func handle(_ data: Data?, handler: ((GameCenter.PlayerReadyMessage) -> Void)? = nil) {
            GameCenter.handleMessage(data, playerReady: handler);
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

        public static func handle(_ data: Data?, handler: ((GameCenter.DealCardsMessage) -> Void)? = nil) {
            GameCenter.handleMessage(data, dealCards: handler);
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

        public static func handle(_ data: Data?, handler: ((GameCenter.FoundSetMessage) -> Void)? = nil) {
            GameCenter.handleMessage(data, foundSet: handler);
        }
    }

    public static func handleMessage(_ data: Data?, _ handler: GameCenter.MessageHandler?) {
        if let data: Data = data,
           let handler: GameCenter.MessageHandler = handler {
            GameCenter.handleMessage(data,
                                     playerReady: handler.handle,
                                     dealCards: handler.handle,
                                     foundSet: handler.handle);
        }
    }

    public static func handleMessage(_ data: Data?,
                                       playerReady: ((GameCenter.PlayerReadyMessage) -> Void)? = nil,
                                       dealCards: ((GameCenter.DealCardsMessage) -> Void)? = nil,
                                       foundSet: ((GameCenter.FoundSetMessage) -> Void)? = nil) {

        struct MessageEnvelope: Decodable {
            let type: GameCenter.MessageType
        }

        if let data = data, let envelope = GameCenter.fromJson(data, MessageEnvelope.self) {
            switch envelope.type {
                case .playerReady:
                    if let message: GameCenter.PlayerReadyMessage = GameCenter.PlayerReadyMessage(data) {
                        playerReady?(message);
                    }
                case .dealCards:
                    if let message: GameCenter.DealCardsMessage = GameCenter.DealCardsMessage(data) {
                        dealCards?(message);
                    }
                case .foundSet:
                    if let message: GameCenter.FoundSetMessage = GameCenter.FoundSetMessage(data) {
                        foundSet?(message);
                    }
            }
        }
    }

    private static func toJson(_ data: GameCenter.Message) -> Data? {
        do {
            return try JSONEncoder().encode(data);
        }
        catch {
            return nil;
        }
    }

    private static func fromJson<T: Decodable>(_ data: Data?, _ type: T.Type) -> T? {
        if let data: Data = data {
            do { return try JSONDecoder().decode(type, from: data); } catch {}
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

public extension GameCenter.Message {

    public init?<T: Decodable>(_ data: Data?, as type: T.Type) {
        guard let decoded = GameCenter.fromJson(data, type) as? Self else { return nil }
        self = decoded;
    }

    public func serialize() -> Data? {
        return GameCenter.toJson(self)
    }
}
