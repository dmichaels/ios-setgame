import Foundation

extension GameCenter
{
    protocol Transport: GameCenter.MessageSender, GameCenter.MessageHandler {
        func configure(handler: MessageHandler);
        var hosting: Bool { get }
    }
}

extension GameCenter
{
    public class HttpTransport: Transport {

        public static let instance: HttpTransport = HttpTransport(player: ID(short: true).value);

        public  let player: String;
        public  var host: String = "";
        private var handler: GameCenter.MessageHandler?;
        private let url: URL;
        private var retrievedCount: Int = 0;
        private var sentCount: Int = 0;

        public var hosting: Bool { self.player == self.host }

        public init(player: String, handler: GameCenter.MessageHandler? = nil, url: URL? = nil) {
            self.player = player;
            self.handler = handler;
            self.url = url ?? URL(string: Defaults.url)!
        }

        public func configure(handler: GameCenter.MessageHandler) {
            self.handler = handler;
            self.startMessagePolling();
        }

        private struct Defaults {
            public static let url: String             = "http://127.0.0.1:5000";
            public static let contentType: String     = "application/json";
            public static let contentTypeName: String = "Content-Type";
            public static let pollingInterval: UInt64 = 300_000_000; // 2s // 100_000_000; // 100s
        }

        private var pollingTask: Task<Void, Never>? = nil;

        public func send(message: GameCenter.Message) {
            Task {
                if (self.hosting) {
                    let players: [String] = await self.retrievePlayers();
                    for player in players {
                        self.sendMessage(message: message, to: player);
                    }
                }
                else if (self.host != "") {
                    self.sendMessage(message: message, to: self.host);
                }
            }
        }

        public func handle(message: GameCenter.PlayerReadyMessage) {
            self.handler?.handle(message: message);
        }

        public func handle(message: GameCenter.NewGameMessage) {
            self.handler?.handle(message: message);
        }

        public func handle(message: GameCenter.FoundSetMessage) {
            self.handler?.handle(message: message);
        }

        public func handle(message: GameCenter.ConfirmedSetMessage) {
            self.handler?.handle(message: message);
        }

        private func sendMessage(message: GameCenter.Message, to player: String? = nil) {
            self.sendMessage(data: message.serialize(), to: player ?? message.player);
        }

        private func sendMessage(data: Data?, to player: String) {
            guard let data = data else { return }
            let url: URL = URL(string: "/send", relativeTo: self.url)!;
            if let payload = try? JSONSerialization.jsonObject(with: data) {
                var body: [String: Any] = [String: Any](); // instead of decode/reencoded build wrapper manually
                body["to"] = player;
                body["message"] = payload;
                var request: URLRequest = URLRequest(url: url);
                request.httpMethod = "POST";
                request.setValue(Defaults.contentType, forHTTPHeaderField: Defaults.contentTypeName);
                request.httpBody = try? JSONSerialization.data(withJSONObject: body);
                URLSession.shared.dataTask(with: request).resume();
                self.sentCount += 1;
            }
        }

        public func retrieveMessages(for player: String) async -> [GameCenter.Message] {
            let url: URL = URL(string: "/receive/\(player)", relativeTo: self.url)!;
            if let response = try? await URLSession.shared.data(from: url) {
                let data: Data = response.0;
                if let messages: [GameCenter.Message] = GameCenter.toMessages(data: data) {
                    self.retrievedCount += messages.count;
                    return messages;
                }
            }
            return [];
        }

        public func retrieveMessageQueuedCount(for player: String? = nil) async -> Int {
            let player: String = player ?? self.player;
            struct MessageEnvelope: Decodable { let player: String ; let count: Int }
            let url: URL = URL(string: "/count/\(player)", relativeTo: self.url)!;
            if let response = try? await URLSession.shared.data(from: url) {
                let data: Data = response.0;
                if let envelope = try? JSONDecoder().decode(MessageEnvelope.self, from: data) {
                    return envelope.count;
                }
            }
            return 0;
        }

        public func messageSentCount() -> Int {
            return self.sentCount;
        }

        public func messageRetrievedCount() -> Int {
            return self.retrievedCount;
        }

	    public func register() async {
            if let response: (player: String, host: String) = await self.registerPlayer(self.player) {
                self.host = response.host;
                print("REGISTER!!! player: \(self.player) host: \(self.host) hosting: \(self.hosting)");
            }
        }

	    public func registerPlayer(_ player: String? = nil) async -> (player: String, host: String)? {
            let player: String = player ?? self.player;
		    struct Response: Decodable { let player: String ; let host: String };
    	    let baseURL = URL(string: "http://127.0.0.1:5000")!
    	    let url = baseURL.appendingPathComponent("register/\(player)")
    	    var request = URLRequest(url: url)
    	    request.httpMethod = "POST"
    	    if let response = try? await URLSession.shared.data(for: request) {
                let data: Data = response.0;
                if let response: [String: String] = try? JSONSerialization.jsonObject(with: data) as? [String: String] {
                    if let player = response["player"], let host = response["host"] {
                        return (player: player, host: host);
                    }
                }
            }
            return nil;
	    }

        public func retrievePlayers() async -> [String] {
            let url: URL = URL(string: "/players", relativeTo: self.url)!;
            if let response = try? await URLSession.shared.data(from: url) {
                let data: Data = response.0;
                if let players = try? JSONDecoder().decode([String].self, from: data) {
                    return players;
                }
            }
            return [];
        }

		public func reset() async -> Bool {
            let url: URL = URL(string: "/reset", relativeTo: self.url)!;
    		var request = URLRequest(url: url);
    		request.httpMethod = "POST";
            if let response = try? await URLSession.shared.data(for: request) {
                let data: Data = response.0;
        		if let response = response.1 as? HTTPURLResponse, response.statusCode == 200 {
        		    let result = String(data: data, encoding: .utf8);
                    print("RESET!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                    print(result)
                    return true;
                }
            }
            return false;
		}

		public func resetHost() async -> Bool {
            let url: URL = URL(string: "/resethost", relativeTo: self.url)!;
    		var request = URLRequest(url: url);
    		request.httpMethod = "POST";
            if let response = try? await URLSession.shared.data(for: request) {
                let data: Data = response.0;
        		if let response = response.1 as? HTTPURLResponse, response.statusCode == 200 {
        		    let result = String(data: data, encoding: .utf8);
                    print("RESET-HOST!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                    print(result)
                    return true;
                }
            }
            return false;
		}

        private func dispatchMessages(messages: [GameCenter.Message]) {
            DispatchQueue.main.async {
                GameCenter.dispatch(messages: messages, handler: self);
            }
        }

        public func startMessagePolling() {
            guard self.pollingTask == nil else { return }
            self.pollingTask = Task {
                while (!Task.isCancelled) {
                    let messages: [GameCenter.Message] = await self.retrieveMessages(for: self.player);
                    print("POLL-MESSAGES(\(self.player)): \(messages)")
                    self.dispatchMessages(messages: messages);
                    try? await Task.sleep(nanoseconds: Defaults.pollingInterval);
                }
            }
        }

        public func stopMessagePolling() {
            pollingTask?.cancel();
            pollingTask = nil;
        }
    }
}
