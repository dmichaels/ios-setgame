import Foundation

public extension XGameCenter.Message
{
    fileprivate init?(_ data: Data?, internal: Bool) {
        guard let message = XGameCenter.toMessage(data: data) as? Self else { return nil }
        self = message;
    }
}

public extension XGameCenter.Message
{
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
    public static func toMessage(data: Data?) -> Message? {
        struct MessageEnvelope: Decodable { let type: MessageType; }
        if let data: Data = data,
           let envelope: MessageEnvelope = try? JSONDecoder().decode(MessageEnvelope.self, from: data) {
            switch envelope.type {
            case .ping:         return try? JSONDecoder().decode(PingMessage.self, from: data);
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

        public init?(_ data: Data?) {
            self.init(data, internal: true);
        }

        public init(player: String) {
            self.type   = .ping;
            self.player = player;
        }
    }
}
