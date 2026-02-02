import Foundation

public extension XGameCenter
{
    public class HttpTransport: XGameCenter.Transport {

        // Transport protocol implementation.

        public var player: String = ID(veryshort: true).value;

        public func start() {
            //
            // TODO
            //
        }

        public func stop() {
            //
            // TODO
            //
        }

        public func bind(to handler: XGameCenter.MessageHandler) {  // Transport imp
            self.handler = handler;
            handler.sender = self;
        }

        // MessageSender protocol implementation.

        public func send(message: Message) {
            self.sendMessage(message);
        }

        // MessageHandler protocol implementation.

        public var sender: MessageSender? {
            get { self }
            set { }
        }

        public func handle(message: PingMessage) {
            self.handler?.handle(message: message);
            self.counts.handled += 1;
        }

        public func handle(message: PlayerReadyMessage) {
            self.handler?.handle(message: message);
            self.counts.handled += 1;
        }

        public func handle(message: NewGameMessage) {
            self.handler?.handle(message: message);
            self.counts.handled += 1;
        }

        public func handle(message: FoundSetMessage) {
            self.handler?.handle(message: message);
            self.counts.handled += 1;
        }

        public func handle(message: ConfirmedSetMessage) {
            self.handler?.handle(message: message);
            self.counts.handled += 1;
        }

        // HttpTransport class implementation.

        private struct Defaults {
            public static let url: String             = "http://127.0.0.1:5000";
            public static let contentType: String     = "application/json";
            public static let contentTypeName: String = "Content-Type";
            public static let pollingInterval: UInt64 = 300_000_000; // 300ms
        }

        private struct Counts {
            public var sent: Int = 0;
            public var retrieved: Int = 0;
            public var handled: Int = 0;
        }

        private let url: URL;
        private var handler: XGameCenter.MessageHandler? = nil;
        private var counts: Counts = Counts();

        public init(player: String? = nil,  url: URL? = nil) {
            self.player = player ?? ID(veryshort: true).value;
            self.url = url ?? URL(string: Defaults.url)!
        }

        public func sendMessage(_ message: Message, to player: String? = nil) {
            guard let payload = message.json else { return }
            let body: [String: Any] = [
                "to": player ?? message.player,
                "message": payload
            ]
            if self.url.post("send", data: body) {
                self.counts.sent += 1;
            }
        }

        public func retrieveMessages(for player: String? = nil) async -> [GameCenter.Message] {
            if let data: Data = await self.url.get("/receive", player ?? self.player) {
                if let messages: [GameCenter.Message] = GameCenter.toMessages(data: data) {
                    self.counts.retrieved += messages.count;
                    return messages;
                }
            }
            return [];
        }

	    public func register(player: String) async -> (player: String, host: String)? {
		    struct Response: Decodable { let player: String ; let host: String };
            if let response = await self.url.post("register", player, as: Response.self) {
                return (player: response.player, host: response.host);
            }
            return nil;
	    }

        public func retrieveHost() async -> String {
            if let response: [String: Any] = await self.url.get("/host", as: [String: Any].self),
               let host = response["host"] as? String {
                return host;
            }
            return "";
        }

        public func retrieveMessageQueueLength(for player: String? = nil, all: Bool = false) async -> Int {
            struct Response: Decodable { let count: Int };
            if let response: Response = await self.url.get ("/messagecount", all ? nil : (player ?? self.player), as: Response.self) {
                return response.count;
            }
            return 0;
        }
    }
}
