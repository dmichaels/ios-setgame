import Foundation

public extension XGameCenter.Message
{
    public init?(_ data: Data?, internal: Bool) {
        guard let message = XGameCenter.toMessage(data: data) as? Self else { return nil }
        self = message;
    }

    public func serialize() -> Data? {
        do { return try JSONEncoder().encode(self); } catch { return nil; }
    }

    public var json: [String: Any]? {
        if let data = self.serialize(),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            return json;
        }
        return nil;
    }
}

public extension XGameCenter
{
    private static func toMessage(data: Data?) -> Message? {
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
}

public extension XGameCenter
{
    public struct PingMessage: Message {

        public let type: MessageType;
        public let player: String;

        public init(player: String) {
            self.type   = .ping;
            self.player = player;
        }
    }

    public struct PlayerReadyMessage: Message {

        public let type: MessageType;
        public let player: String;

        public init(player: String) {
            self.type   = .playerReady;
            self.player = player;
        }
    }

    public struct NewGameMessage: Message {

        public  let type: MessageType;
        public  let player: String;
        private let cardcodes: [String];
        public  var cards: [TableCard] { return XGameCenter.toCards(self.cardcodes); }

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
        public  var cards: [TableCard] { return XGameCenter.toCards(self.cardcodes); }

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
        public  var cards: [TableCard] { return XGameCenter.toCards(self.cardcodes); }
        public  var replacements: [TableCard] { return XGameCenter.toCards(self.cardcodesReplacements); }

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
