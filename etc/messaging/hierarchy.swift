import Foundation

public struct XGameCenter {}

public extension XGameCenter
{
    public enum MessageType: String, Codable {
        case ping;
    }

    public protocol Message: Codable {
        var  type: MessageType { get };
        var  player: String { get };
        func serialize() -> Data?;
        var  json: [String: Any]? { get };
    }
}

public extension XGameCenter.Message
{
    private init?(_ data: Data?, internal: Bool) {
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

        public init(player: String) {
            self.type   = .ping;
            self.player = player;
        }
    }
}

public extension XGameCenter
{
    public protocol MessageSender {
        func send(message: Message);
    }

    public protocol MessageHandler {
        func handle(message: PingMessage);
        var  sender: MessageSender? { get set }
    }
}

public extension XGameCenter.MessageHandler
{
    public var sender: XGameCenter.MessageSender? { get { nil } set {} }
}

public extension XGameCenter
{
    public protocol Transport_New: MessageSender, MessageHandler {
        var  player: String { get };
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
        var transport: Transport_New { get };
        var session: Session_New { get };
        func start() async;
        func stop();
    }
}

public extension XGameCenter
{
    public class HttpTransport_New: Transport_New {
        public var  handler: MessageHandler?
        public var  player: String = "A";
        public func start() {}
        public func stop() {}
        public func send(message: Message) {}
        public func handle(message: PingMessage) {}
        public func bind(to handler: Table_New) {
            self.handler = handler;
            handler.sender = self;
        }
    }
}

public class Table_New: XGameCenter.MessageHandler {
    public var  sender: XGameCenter.MessageSender?
    public func handle(message: XGameCenter.PingMessage) {}
}


func main() {
    let transport = XGameCenter.HttpTransport_New();
    let table = Table_New();
    transport.bind(to: table);
}

main()
