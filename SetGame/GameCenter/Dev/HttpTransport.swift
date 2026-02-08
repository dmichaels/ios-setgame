import Foundation

public extension GameCenter
{
    public class HttpTransport: Transport {

        // Transport protocol implementation.

        public var player: String = ID(veryshort: true).value;
        public var handler: MessageHandler? = nil;

        public func setup() {
            self.pollInfo();
            self.pollMessages();
        }

        public func release() {
            self.nopollMessages();
        }

        // MessageSender (via Transport) protocol implementation.

        public func send(message: Message, to player: String) {
            if (!player.isEmpty) {
                self.sendMessage(message, to: player);
            }
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

        public func handle(message: FoundSetTooLateMessage) {
            self.handler?.handle(message: message);
            self.info.counts.handled += 1;
        }

        public func handle(message: ConfirmedSetMessage) {
            self.handler?.handle(message: message);
            self.info.counts.handled += 1;
        }

        // HttpTransport class implementation.

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
        private var pollMessagesTask: Task<Void, Never>? = nil;
        private var pollInfoTask: Task<Void, Never>? = nil;
        private var pollTask: Task<Void, Never>? = nil;
        private let pollInterval: UInt64 = 250_000_000; // 250ms (4x per second)
        public  var info: Info = Info();

        public init( /* player: String? = nil, */ url: URL? = nil) {
            // self.player = player ?? ID(veryshort: true).value;
            self.url = url ?? URL(string: Defaults.multiPlayer.server)!
        }

        public func sendMessage(_ message: Message, to player: String) {
            guard let data: [String: Any] = message.json else { return }
            deb("HttpTransport.sendMessage: \(message.type) to: \(player)")
            //
            // Note that this send (POST) is a fire-and-forget;
            // we do not await for its completion and return.
            //
            // If we wanted to await just prepend the post call with await and Swift
            // will automatically choose the async version of our URL.post function.
            //
            if self.url.post("send", data: ["to": player, "message": data]) {
                self.info.counts.sent += 1;
            }
            else {
                deb("HttpTransport.sendMessage: \(message.type) to: \(player) failed")
            }
        }

        public func retrieveMessages(for player: String? = nil) async -> [GameCenter.Message] {
            if let data: Data = await self.url.get("/receive", player ?? self.player) {
                if let messages: [GameCenter.Message] = GameCenter.MessageConversion.toMessages(data: data) {
                    if (messages.count > 0) {
                        deb("HttpTransport.retrieveMessages: \(messages.count) retrieved: \(self.info.counts.retrieved)")
                    }
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

        public func retrievePlayers() async -> Set<String> {
            return await self.url.get("/players", as: Set<String>.self) ?? [];
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

		public func setHost(player: String? = nil) {
            self.url.post("/host", player ?? self.player);
		}

		public func unsetHost(player: String? = nil) {
            self.url.post("/nohost", player ?? self.player);
		}

		public func resetMessages(player: String? = nil, all: Bool = false) {
            if self.url.post("/resetmessages", all ? nil : (player ?? self.player)) {
                self.info.counts.sent = 0;
                self.info.counts.retrieved = 0;
                self.info.counts.handled = 0;
            }
		}

        private func pollMessages() {
            guard self.pollMessagesTask == nil else { return }
            self.pollMessagesTask = Task {
                while (!Task.isCancelled) {
                    let messages: [GameCenter.Message] = await self.retrieveMessages(for: self.player);
                    self.dispatchMessages(messages: messages);
                    try? await Task.sleep(nanoseconds: self.pollInterval);
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
                    try? await Task.sleep(nanoseconds: self.pollInterval);
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
