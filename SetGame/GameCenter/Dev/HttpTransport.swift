import Foundation

public extension GameCenter
{
    public class HttpTransport: Transport {

        // TEMPORARY WHILE MIGRATING TO THIS ...
        public static let instance: HttpTransport = HttpTransport(player: ID(veryshort: true).value); // TEMPORARY
        public var hosting: Bool { self.player == self.info.host }
        public func startMessagePolling() { self.pollMessages() }
        public func stopMessagePolling() { self.nopollMessages() }
        // ... END TEMPORARY WHILE MIGRATING TO THIS

        // Transport protocol implementation.

        public var player: String = ID(veryshort: true).value;

        public func start() {
            self.poll();
        }

        public func stop() {
            self.nopoll();
        }

        // MessageSender (via Transport) protocol implementation.

        public func send(message: Message) {
            self.sendMessage(message);
        }

        // MessageHandler (via Transport) protocol implementation.

        public func handle(message: PingMessage) {
            self.handler?.handle(message: message);
            self.info.counts.handled += 1;
        }

        public func handle(message: PlayerReadyMessage) {
            self.handler?.handle(message: message);
            self.info.counts.handled += 1;
        }

        public func handle(message: NewGameMessage) {
            self.handler?.handle(message: message);
            self.info.counts.handled += 1;
        }

        public func handle(message: FoundSetMessage) {
            self.handler?.handle(message: message);
            self.info.counts.handled += 1;
        }

        public func handle(message: ConfirmedSetMessage) {
            self.handler?.handle(message: message);
            self.info.counts.handled += 1;
        }

        // HttpTransport class implementation.

        private struct Defaults {
            public static let url: String          = "http://127.0.0.1:5000";
            public static let pollInterval: UInt64 = 300_000_000; // 300ms
        }

        public struct Info {
            public struct Counts {
                public var sent: Int = 0;
                public var retrieved: Int = 0;
                public var handled: Int = 0;
                public var queued: Int = 0;
                public var queuedTotal: Int = 0;
                public var players: Int = 0;
            }
            public var counts: Counts = Counts();
            public var host: String = "";
        }

        private let url: URL;
        public var handler: MessageHandler? = nil;
        private var pollMessagesTask: Task<Void, Never>? = nil;
        private var pollInfoTask: Task<Void, Never>? = nil;
        private var pollTask: Task<Void, Never>? = nil;
        public  var info: Info = Info();

        public init(player: String? = nil,  url: URL? = nil) {
            self.player = player ?? ID(veryshort: true).value;
            self.url = url ?? URL(string: Defaults.url)!
        }

        public func sendMessage(_ message: Message, to player: String? = nil) {
            guard let data: [String: Any] = message.json else { return }
            if self.url.post("send", data: ["to": player ?? message.player, "message": data]) {
                self.info.counts.sent += 1;
            }
        }

        public func retrieveMessages(for player: String? = nil) async -> [GameCenter.Message] {
            if let data: Data = await self.url.get("/receive", player ?? self.player) {
                if let messages: [GameCenter.Message] = GameCenter.MessageConversion.toMessages(data: data) {
                    self.info.counts.retrieved += messages.count;
                    return messages;
                }
            }
            return [];
        }

	    public func register(player: String? = nil) async -> (player: String, host: String)? {
		    struct Response: Decodable { let player: String ; let host: String };
            if let response = await self.url.post("register", player ?? self.player, as: Response.self) {
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

        public func retrievePlayers() async -> [String] {
            return await self.url.get("/players", as: [String].self) ?? [];
        }

        public func retrieveMessagesQueuedCount(for player: String? = nil, all: Bool = false) async -> Int {
            struct Response: Decodable { let count: Int };
            if let response: Response = await self.url.get ("/messagecount", all ? nil : (player ?? self.player), as: Response.self) {
                return response.count;
            }
            return 0;
        }

		public func reset() {
            self.url.post("/reset");
		}

		public func resetHost() {
            self.url.post("/resethost");
		}

		public func setHost(host: String? = nil) {
            self.url.post("/host", host ?? self.player);
		}

		public func unsetHost() {
            self.url.post("/nohost");
		}

		public func resetMessages(player: String? = nil, all: Bool = false) {
            if self.url.post("/resetmessages", all ? nil : (player ?? self.player)) {
                self.info.counts.sent = 0;
                self.info.counts.retrieved = 0;
                self.info.counts.handled = 0;
            }
		}

        private func poll() {
            self.pollMessages();
            self.pollInfo();
        }

        private func pollMessages() {
            guard self.pollMessagesTask == nil else { return }
            self.pollMessagesTask = Task {
                while (!Task.isCancelled) {
                    let messages: [GameCenter.Message] = await self.retrieveMessages(for: self.player);
                    self.dispatchMessages(messages: messages);
                    try? await Task.sleep(nanoseconds: Defaults.pollInterval);
                }
            }
        }

        private func pollInfo() {
            guard self.pollInfoTask == nil else { return }
            self.pollInfoTask = Task {
                while (!Task.isCancelled) {
                    self.info.counts.queued = await self.retrieveMessagesQueuedCount();
                    self.info.counts.queuedTotal = await self.retrieveMessagesQueuedCount(all: true);
                    self.info.counts.players = await self.retrievePlayers().count;
                    self.info.host = await self.retrieveHost();
                    try? await Task.sleep(nanoseconds: Defaults.pollInterval);
                }
            }
        }

        private func nopoll() {
            self.nopollMessages();
            self.nopollInfo();
        }

        private func nopollMessages() {
            self.pollMessagesTask?.cancel();
            self.pollMessagesTask = nil;
        }

        private func nopollInfo() {
            self.pollInfoTask?.cancel();
            self.pollInfoTask = nil;
        }

        private func dispatchMessages(messages: [GameCenter.Message]) {
            DispatchQueue.main.async {
                GameCenter.MessageConveyance.dispatch(messages: messages, handler: self);
            }
        }
    }
}
