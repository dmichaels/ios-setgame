import SwiftUI

public enum GameCenter {}

public extension GameCenter
{
    // TODO
    // Think about message sending restrictions to
    // and from client/host depending on message type.
    //
    // ping:         any
    // playerReady:  undecided
    // newGame:      host   -> client | host -> host
    // foundSet:     client -> host   | host -> host
    // confirmedSet: host   -> client | host -> host
    //
    public enum MessageType: String, Codable {
        case ping;
        case playerReady;
        case newGame;
        case foundSet;
        case confirmedSet;
    }

    public protocol Message: Codable {
        var type: MessageType { get };
        var player: String { get };
        func serialize() -> Data?;
    }

    public protocol MessageHandler: AnyObject {
        func handle(message: PingMessage);
        func handle(message: PlayerReadyMessage);
        func handle(message: NewGameMessage);
        func handle(message: FoundSetMessage);
        func handle(message: ConfirmedSetMessage);
    }

    public protocol MessageSender: AnyObject {
        func send(message: Message);
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

// TODO: Suggested by ChatGPT ...
// Transport_New (rename to Transport) and Session_New (rename to Session).
//
public extension GameCenter
{
    public protocol Transport_New {
        var  player: String { get };
        var  handler: MessageHandler? { get set }
        func send(_ message: Message);
        func start();
        func stop();
    }

    public protocol Session_New {
        var player: String { get };
        var host: String { get };
        var hosting: Bool { get };
        var players: [String] { get };
    }

    public protocol Manager_New {
        var session: Session_New { get };
        var transport: Transport_New { get };
        func start() async;
        func stop();
    }

    public final class Manager_New_Old {

        private let transport: GameCenter.Transport_New;
        private let session: GameCenter.Session_New;
        private let hostOnlyMessages: [GameCenter.MessageType] = [.newGame, .confirmedSet];

        public init(transport: Transport_New, session: Session_New) {
            self.transport = transport;
            self.session = session;
        }

        public var hosting: Bool {
            self.session.hosting;
        }

        public func send(_ message: GameCenter.Message) {
            if self.session.hosting {
                for player in session.players {
                    transport.send(message);
                }
            } else if (!self.hostOnlyMessages.contains(message.type)) {
                transport.send(message);
            }
        }
    }
}

public extension GameCenter.Session_New {
    var hosting: Bool { self.player == self.host };
}

public extension GameCenter
{
    public struct PingMessage: Message {

        public let type: MessageType;
        public let player: String;

        public init?(_ data: Data?) {
            self.init(data, internal: true);
        }

        public init(player: String) {
            self.type   = .ping;
            self.player = player;
        }
    }

    public struct PlayerReadyMessage: Message {

        public let type: MessageType;
        public let player: String;

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

    public struct ConfirmedSetMessage: Message {

        public  let type: MessageType;
        public  let player: String;
        private let cardcodes: [String];
        private let cardcodesReplacements: [String];
        public  var cards: [TableCard] { return GameCenter.toCards(self.cardcodes); }
        public  var replacements: [TableCard] { return GameCenter.toCards(self.cardcodesReplacements); }

        public init?(_ data: Data?) { self.init(data, internal: true); }

        public init(player: String, cards: [Card], replacements: [Card]) {
            self.type      = .confirmedSet;
            self.player    = player;
            self.cardcodes = cards.map { $0.code };
            self.cardcodesReplacements = cards.map { $0.code };
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
            case .ping:         return try? JSONDecoder().decode(PingMessage.self, from: data);
            case .playerReady:  return try? JSONDecoder().decode(PlayerReadyMessage.self, from: data);
            case .newGame:      return try? JSONDecoder().decode(NewGameMessage.self, from: data);
            case .foundSet:     return try? JSONDecoder().decode(FoundSetMessage.self, from: data);
            case .confirmedSet: return try? JSONDecoder().decode(ConfirmedSetMessage.self, from: data);
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
    private static func dispatch(data: Data?,
                                 ping: ((PingMessage) -> Void)? = nil,
                                 playerReady: ((PlayerReadyMessage) -> Void)? = nil,
                                 newGame: ((NewGameMessage) -> Void)? = nil,
                                 foundSet: ((FoundSetMessage) -> Void)? = nil,
                                 confirmedSet: ((ConfirmedSetMessage) -> Void)? = nil) {
        if let messages: [Message] = GameCenter.toMessages(data: data) {
            GameCenter.dispatch(messages: messages,
                                ping: ping,
                                playerReady: playerReady,
                                newGame: newGame,
                                foundSet: foundSet,
                                confirmedSet: confirmedSet);
        }
    }

    public static func dispatch(message: Message?,
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

    private static func dispatch(messages: [Message]?,
                                 ping: ((PingMessage) -> Void)? = nil,
                                 playerReady: ((PlayerReadyMessage) -> Void)? = nil,
                                 newGame: ((NewGameMessage) -> Void)? = nil,
                                 foundSet: ((FoundSetMessage) -> Void)? = nil,
                                 confirmedSet: ((ConfirmedSetMessage) -> Void)? = nil) {
        if let messages: [Message] = messages {
            for message: Message in messages {
                GameCenter.dispatch(message: message,
                                    ping: ping,
                                    playerReady: playerReady,
                                    newGame: newGame,
                                    confirmedSet: confirmedSet);
            }
        }
    }

    // TODO: Probably dont need both these kind and the above kind ...
    // These dispatch calls may look weird, the three handler.handle references in a row,
    // but Swift typing works it magic and sorts it; so that for example, handler.handle for
    // newGame handler.handle references MessageHandler.handle(message: NewGameMessage).
    //
    private static func dispatch(data: Data?, handler: MessageHandler) {
        GameCenter.dispatch(data: data,
                            ping: handler.handle,
                            playerReady: handler.handle,
                            newGame: handler.handle,
                            foundSet: handler.handle,
                            confirmedSet: handler.handle);
    }

    private static func dispatch(message: Message?, handler: MessageHandler) {
        GameCenter.dispatch(message: message,
                            ping: handler.handle,
                            playerReady: handler.handle,
                            newGame: handler.handle,
                            foundSet: handler.handle,
                            confirmedSet: handler.handle);
    }

    public static func dispatch(messages: [Message]?, handler: MessageHandler) {
        GameCenter.dispatch(messages: messages,
                            ping: handler.handle,
                            playerReady: handler.handle,
                            newGame: handler.handle,
                            foundSet: handler.handle,
                            confirmedSet: handler.handle);
    }
}
