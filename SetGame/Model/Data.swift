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
        init?(_ data: Data)
        func serialize() -> Data?
    }

    public struct PlayerReadyMessage: Message {

        public let type: MessageType;
        public let player: String

        public init?(_ data: Data) {
            self.init(data, as: GameCenter.PlayerReadyMessage.self);
        }

        public init(player: String, cards: [Card]) {
            self.type   = MessageType.playerReady;
            self.player = player;
        }
    }

    public struct FoundSetMessage: Message {

        public let type: MessageType;
        public let player: String;
        public let cardcodes: [String];

        public init?(_ data: Data) {
            self.init(data, as: GameCenter.FoundSetMessage.self);
        }

        public init(player: String, cards: [Card]) {
            self.type      = MessageType.foundSet;
            self.player    = player;
            self.cardcodes = cards.map { $0.codename };
        }

        public var cards: [TableCard] {
            return GameCenter.toCards(self.cardcodes).map { TableCard($0) }
        }
    }

    public struct DealCardsMessage: Message {

        public  let type: MessageType;
        public  let player: String;
        private let cardcodes: [String];

        public init?(_ data: Data) {
            self.init(data, as: GameCenter.DealCardsMessage.self);
        }

        public init(player: String, cards: [Card]) {
            self.type      = MessageType.dealCards;
            self.player    = player;
            self.cardcodes = cards.map { $0.codename };
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

    private static func fromJson<T: Decodable>(_ data: Data, _ type: T.Type) -> T? {
        do {
            return try JSONDecoder().decode(type, from: data);
        } catch {
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

private extension GameCenter.Message {

    public init?<T: Decodable>(_ data: Data, as type: T.Type) {
        guard let decoded = GameCenter.fromJson(data, type) as? Self else { return nil }
        self = decoded
    }

    public func serialize() -> Data? {
        return GameCenter.toJson(self)
    }
}
