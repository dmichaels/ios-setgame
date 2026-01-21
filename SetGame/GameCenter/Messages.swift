import SwiftUI

public enum GameCenter {

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

    private struct MessageEnvelope: Decodable {
        let type: GameCenter.MessageType
    }

    public static func receiveMessage(_ data: Data?,
                                        playerReady: ((GameCenter.PlayerReadyMessage) -> Void)? = nil,
                                        dealCards: ((GameCenter.DealCardsMessage) -> Void)? = nil,
                                        foundSet: ((GameCenter.FoundSetMessage) -> Void)? = nil) {

        // if let data = data, let envelope = try? JSONDecoder().decode(MessageEnvelope.self, from: data) {
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
}

public extension GameCenter.Message {

    init?<T: Decodable>(_ data: Data?, as type: T.Type) {
        guard let decoded = GameCenter.fromJson(data, type) as? Self else { return nil }
        self = decoded
    }

    func serialize() -> Data? {
        return GameCenter.toJson(self)
    }
}
