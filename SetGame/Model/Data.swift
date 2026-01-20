import SwiftUI

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

////

protocol GameMessage: Codable {
    var type: GameMessageType { get }
    var player: String { get }
}

enum GameMessageType: String, Codable {
    case playerReady
    case dealCards
    case notifySet
}

struct PlayerReadyMessage: GameMessage {
    let type: GameMessageType = .playerReady
    let player: String
}

struct DealCardsMessage: GameMessage {
    let type: GameMessageType = .dealCards
    let player: String
    let cards: [String]
}
