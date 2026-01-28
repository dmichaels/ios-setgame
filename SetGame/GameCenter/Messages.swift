import SwiftUI

public enum GameCenter {}

public extension GameCenter
{
    public enum MessageType: String, Codable {
        case playerReady;
        case newGame;
        case foundSet;
    }

    public protocol Message: Codable {
        var type: MessageType { get };
        var player: String { get };
        func serialize() -> Data?;
    }

    public protocol MessageHandler: AnyObject {
        func handle(message: PlayerReadyMessage);
        func handle(message: NewGameMessage);
        func handle(message: FoundSetMessage);
    }

    public protocol MessageSender: AnyObject {
        func send(message: Message);
        // func send(message: PlayerReadyMessage);
        // func send(message: NewGameMessage);
        // func send(message: FoundSetMessage);
    }
}

public extension GameCenter.Message
{
    fileprivate init?(_ data: Data?, internal: Bool) {
        guard let message = GameCenter.toMessage(data: data) as? Self else { return nil }
        self = message;
    }

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
            self.init(data, internal: true);
        }

        public init(player: String) {
            self.type   = .playerReady;
            self.player = player;
        }
    }

    public struct NewGameMessage: Message {

        public  let type: MessageType;
        public  let player: String;
        private let cardcodes: [String];
        public  var cards: [TableCard] { return GameCenter.toCards(self.cardcodes); }

        public init?(_ data: Data?) {
            self.init(data, internal: true);
        }

        public init(player: String, cards: [Card]) {
            self.type      = .newGame;
            self.player    = player;
            self.cardcodes = cards.map { $0.code };
        }
    }

    public struct FoundSetMessage: Message {

        public  let type: MessageType;
        public  let player: String;
        private let cardcodes: [String];
        public  var cards: [TableCard] { return GameCenter.toCards(self.cardcodes); }

        public init?(_ data: Data?) { self.init(data, internal: true); }

        public init(player: String, cards: [Card]) {
            self.type      = .foundSet;
            self.player    = player;
            self.cardcodes = cards.map { $0.code };
        }
    }

    private static func toCards(_ codes: [String]) -> [TableCard] {
        return codes.compactMap { TableCard($0) };
    }
}

public extension GameCenter
{
    public static func toMessage(data: Data?) -> Message? {
        struct MessageEnvelope: Decodable { let type: MessageType; }
        if let data: Data = data,
           let envelope: MessageEnvelope = try? JSONDecoder().decode(MessageEnvelope.self, from: data) {
            switch envelope.type {
            case .playerReady: return try? JSONDecoder().decode(PlayerReadyMessage.self, from: data);
            case .newGame:     return try? JSONDecoder().decode(NewGameMessage.self, from: data);
            case .foundSet:    return try? JSONDecoder().decode(FoundSetMessage.self, from: data);
            }
        }
        return nil;
    }

    public static func toMessages(data: Data?) -> [Message]? {
        if let data: Data = data,
           let array: [[String: Any]] = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            var messages: [Message] = []; messages.reserveCapacity(array.count);
            let decoder: JSONDecoder = JSONDecoder();
            for object: [String: Any] in array {
                if JSONSerialization.isValidJSONObject(object),
                   let item: Data = try? JSONSerialization.data(withJSONObject: object) {
                    if let message: Message = toMessage(data: item) {
                        messages.append(message);
                    }
                }
            }
            return messages;
        }
        return nil;
    }
}

public extension GameCenter
{
    public static func dispatch(data: Data?,
                                playerReady: ((PlayerReadyMessage) -> Void)? = nil,
                                newGame: ((NewGameMessage) -> Void)? = nil,
                                foundSet: ((FoundSetMessage) -> Void)? = nil) {
        if let messages: [Message] = GameCenter.toMessages(data: data) {
            GameCenter.dispatch(messages: messages,
                                playerReady: playerReady,
                                newGame: newGame,
                                foundSet: foundSet);
        }
    }

    public static func dispatch(message: Message?,
                                playerReady: ((PlayerReadyMessage) -> Void)? = nil,
                                newGame: ((NewGameMessage) -> Void)? = nil,
                                foundSet: ((FoundSetMessage) -> Void)? = nil) {
        if let message: Message = message {
            switch message {
            case let message as PlayerReadyMessage: playerReady?(message);
            case let message as NewGameMessage: newGame?(message);
            case let message as FoundSetMessage: foundSet?(message);
            default: break;
            }
        }
    }

    public static func dispatch(messages: [Message]?,
                                playerReady: ((PlayerReadyMessage) -> Void)? = nil,
                                newGame: ((NewGameMessage) -> Void)? = nil,
                                foundSet: ((FoundSetMessage) -> Void)? = nil) {
        if let messages: [Message] = messages {
            for message: Message in messages {
                GameCenter.dispatch(message: message,
                                    playerReady: playerReady,
                                    newGame: newGame,
                                    foundSet: foundSet);
            }
        }
    }

    // These dispatch calls may look weird, the three handler.handle references in a row,
    // but Swift typing works it magic and sorts it; so that for example, handler.handle for
    // newGame handler.handle references MessageHandler.handle(message: NewGameMessage).
    //
    public static func dispatch(data: Data?, handler: MessageHandler) {
        GameCenter.dispatch(data: data,
                            playerReady: handler.handle,
                            newGame: handler.handle,
                            foundSet: handler.handle);
    }

    public static func dispatch(message: Message?, handler: MessageHandler) {
        GameCenter.dispatch(message: message,
                            playerReady: handler.handle,
                            newGame: handler.handle,
                            foundSet: handler.handle);
    }

    public static func dispatch(messages: [Message]?, handler: MessageHandler) {
        GameCenter.dispatch(messages: messages,
                            playerReady: handler.handle,
                            newGame: handler.handle,
                            foundSet: handler.handle);
    }
}
