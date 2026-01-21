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
        func serialize() -> Data?
        init?(_ data: Data)
    }

    public struct PlayerReadyMessage: Message {
        public let type: MessageType = .playerReady
        public let player: String
        public func serialize() -> Data? { return GameCenter.toJson(self); }
        public init?(_ data: Data) {
            if let message: PlayerReadyMessage = GameCenter.fromJson(data, GameCenter.PlayerReadyMessage.self) {
                self.player = message.player;
            }
            else {
                return nil;
            }
        }
    }

    public struct FoundSetMessage: Message {

        public  let type: MessageType;
        public  let player: String;
        private let cardcodes: [String];

        public func serialize() -> Data? {
            return GameCenter.toJson(self);
        }

        public init?(_ data: Data) {
            if let message: FoundSetMessage = GameCenter.fromJson(data, GameCenter.FoundSetMessage.self) {
                self.type      = message.type;
                self.player    = message.player;
                self.cardcodes = message.cardcodes;
            }
            else {
                return nil;
            }
        }

        public lazy var cards: [Card] = {
            return GameCenter.toCards(self.cardcodes);
        }()
    }

    public struct DealCardsMessage: Message {

        public  let type: MessageType;
        public  let player: String;
        private let cardcodes: [String];

        public lazy var cards: [Card] = {
            return GameCenter.toCards(self.cardcodes);
        }()

        public func serialize() -> Data? {
            return GameCenter.toJson(self);
        }

        public init?(_ data: Data) {
            if let message: DealCardsMessage = GameCenter.fromJson(data, GameCenter.DealCardsMessage.self) {
                self.type      = message.type;
                self.player    = message.player;
                self.cardcodes = message.cardcodes;
            }
            else {
                return nil;
            }
        }

        public init(player: String, cards: [Card]) {
            self.type      = MessageType.dealCards;
            self.player    = player;
            self.cardcodes = cards.map { $0.codename };
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
