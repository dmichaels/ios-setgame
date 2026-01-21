import SwiftUI

/*
public class XGameMessage: Codable {

    public let type: String;
    public let player: String;
    public let payload: [String: String];

    public init(type: String, player: String, payload: [String: String]) {
        self.type = type;
        self.player = player;
        self.payload = payload;
    }

    public static func toJson(_ data: XGameMessage) -> Data? {
        do {
            return try JSONEncoder().encode(data);
        }
        catch {
            return nil;
        }
    }

    public static func fromJson<T: Decodable>(_ data: Data, _ type: T.Type) -> T? {
        do {
            return try JSONDecoder().decode(type, from: data);
        } catch {
            return nil;
        }
    }
}

class GameMessageDealCards: XGameMessage {

    public func toJson() -> Data? {
        return XGameMessage.toJson(self);
    }

    public static func fromJson(_ data: Data) -> GameMessageDealCards? {
        return XGameMessage.fromJson(data, GameMessageDealCards.self);
    }
}
*/

////

public enum GameCenter {

    public enum MessageType: String, Codable {
        case playerReady
        case dealCards
        case notifySet
    }

    public protocol Message: Codable {
        var type: MessageType { get }
        var player: String { get }
        func serialize() -> Data?
        init?(_ data: Data)
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

    public struct DealCardsMessage: Message {
        public let type: MessageType;
        public let player: String;
        public let cards: [String];
        public func serialize() -> Data? { return GameCenter.toJson(self); }
        public init?(_ data: Data) {
            if let message: DealCardsMessage = GameCenter.fromJson(data, GameCenter.DealCardsMessage.self) {
                self.type   = message.type;
                self.player = message.player;
                self.cards  = message.cards;
            }
            else {
                return nil;
            }
        }
        public init(player: String, cards: [Card]) {
            self.type = .dealCards
            self.player = player
            self.cards = cards.map { $0.codename }
        }
    }
}
