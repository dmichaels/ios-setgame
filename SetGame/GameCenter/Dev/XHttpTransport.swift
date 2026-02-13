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

        private var session: String?;
        private let url: URL;
        private let key: String;
        private var pollMessagesTask: Task<Void, Never>? = nil;
        private var pollInfoTask: Task<Void, Never>? = nil;
     // private let pollInterval: UInt64 = 250_000_000;   //  250ms (4x per second)
        private let pollInterval: UInt64 = 1_000_000_000; // 1000ms (1x per second)
        public  var info: Info = Info();

        public init( /* player: String? = nil, */ url: URL? = nil) {
            // self.player = player ?? ID(veryshort: true).value;
            self.url = url ?? URL(string: Defaults.multiPlayer.server)!
            self.key = Defaults.multiPlayer.apikey;
        }

        public func createSession() async -> String? {
            if let response: Json = await self.url.post("/session", as: Json.self, key: self.key) {
                if let session: String = response["session"] as? String {
                    self.session = session;
                    return session;
                }
            }
            return nil;
        }

        public func destroySession() async {
            if let session: String = self.session {
                if let response = await self.url.post("/session", session, "destroy", as: Json.self, key: self.key) {
                    let x = 1
                }
            }
        }

	    public func register(player: String? = nil) async -> (player: String, host: String)? {
            if let response: Json = await self.url.post(self.session, "register", player ?? self.player, as: Json.self, key: self.key),
               let player: String = response["player"] as? String,
               let host: String = response["host"] as? String {
                return (player: player, host: host);
            }
            return nil;
	    }

        public func retrieveHost() async -> String {
            if let response: Json = await self.url.get(self.session, "host", as: Json.self, key: self.key),
               let host = response["host"] as? String {
                return host;
            }
            return "";
        }

        public func retrievePlayers() async -> [String] {
            if let response: Json = await self.url.get(self.session, "players", as: Json.self, key: self.key),
               let players: [String] = response["players"] as? [String] {
                return players;
            }
            return [];
        }

        public func retrieveMessagesQueuedCount(for player: String? = nil, all: Bool = false) async -> Int {
            let player: String? = all ? nil : (player ?? self.player);
            if let response: Json = await self.url.get (self.session, "count", player, as: Json.self, key: self.key),
               let count: Int = response["count"] as? Int {
                return count;
            }
            return 0;
        }

        public func f(_ message: Message, to player: String) async {
            if let data: [String: Any] = message.json {
                await self.url.post(self.session, "send", player, data: data, as: Json.self, key: self.key);
            }
        }

        public func sendMessage(_ message: Message, to player: String) {
            if let data: [String: Any] = message.json {
                //
                // Note that this send (POST) is a fire-and-forget;
                // we do not await for its completion and return.
                //
                // If we wanted to await just prepend the post call with await and Swift
                // will automatically choose the async version of our URL.post function.
                //
                if self.url.post(self.session, "send", player, data: data, key: self.key) {
                    self.info.counts.sent += 1;
                }
            }
        }

        public func retrieveMessages(for player: String? = nil) async -> [GameCenter.Message] {
            if let data: Data = await self.url.get(self.session, "receive", player ?? self.player, key: self.key) {
                if let messages: [GameCenter.Message] = GameCenter.MessageConversion.toMessages(data: data) {
                    if (messages.count > 0) {
                        let x = 1
                    }
                    self.info.counts.retrieved += messages.count;
                    return messages;
                }
            }
            return [];
        }

        public func old_sendMessage(_ message: Message, to player: String) {
            guard let data: [String: Any] = message.json else { return }
            deb("HttpTransport.sendMessage: \(message.type) to: \(player)")
            //
            // Note that this send (POST) is a fire-and-forget;
            // we do not await for its completion and return.
            //
            // If we wanted to await just prepend the post call with await and Swift
            // will automatically choose the async version of our URL.post function.
            //
            if self.url.post("send", data: ["to": player, "message": data], key: self.key) {
                self.info.counts.sent += 1;
            }
            else {
                deb("HttpTransport.sendMessage: \(message.type) to: \(player) failed")
            }
        }

        public func old_retrieveMessages(for player: String? = nil) async -> [GameCenter.Message] {
            if let data: Data = await self.url.get("/receive", player ?? self.player, key: self.key) {
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

	    public func old_register(player: String? = nil) async -> (player: String, host: String)? {
		    struct Response: Decodable { let player: String ; let host: String };
            if let response = await self.url.post("register", player ?? self.player, as: Response.self, key: self.key) {
                return (player: response.player, host: response.host);
            }
            return nil;
	    }

        public func old_retrieveHost() async -> String {
            if let response: [String: Any] = await self.url.get("/host", as: [String: Any].self, key: self.key),
               let host = response["host"] as? String {
                return host;
            }
            return "";
        }

        public func old_retrievePlayers() async -> Set<String> {
            return await self.url.get("/players", as: Set<String>.self, key: self.key) ?? [];
        }

        public func old_retrieveMessagesQueuedCount(for player: String? = nil, all: Bool = false) async -> Int {
            struct Response: Decodable { let count: Int };
            if let response: Response = await self.url.get("/messagecount", all ? nil : (player ?? self.player), as: Response.self, key: self.key) {
                return response.count;
            }
            return 0;
        }

		public func reset() {
            self.url.post("/reset", key: self.key);
		}

		public func resetHost() {
            self.url.post("/resethost", key: self.key);
		}

		public func setHost(player: String? = nil) {
            self.url.post("/host", player ?? self.player, key: self.key);
		}

		public func unsetHost(player: String? = nil) {
            self.url.post("/nohost", player ?? self.player, key: self.key);
		}

		public func resetMessages(player: String? = nil, all: Bool = false) {
            if self.url.post("/resetmessages", all ? nil : (player ?? self.player), key: self.key) {
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

        private func dispatchMessages(messages: [GameCenter.Message]) { // TODO: PUT IN pollMessages
            DispatchQueue.main.async {
                GameCenter.MessageConveyance.dispatch(messages: messages, handler: self);
            }
        }
    }
}
