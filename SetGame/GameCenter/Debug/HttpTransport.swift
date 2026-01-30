import Foundation

public let AID: String = ID(veryshort: true).value;

extension GameCenter
{
    protocol Transport: GameCenter.MessageSender, GameCenter.MessageHandler {
        var handler: MessageHandler? { get set }
        var hosting: Bool { get } // TODO get rid of - move to Session_New
    }
}

extension GameCenter
{
    public class HttpTransport_New: Transport_New {

        public private(set) var player: String = ID(veryshort: true).value; // Transport_New imp
        public              var handler: MessageHandler? = nil;  // Transport_New imp

        public func send(_ message: Message) { // Transport_New imp
        }

        public func start() { // Transport_New imp
        }

        public func stop() { // Transport_New imp
        }

        private struct Defaults {
            public static let url: String             = "http://127.0.0.1:5000";
            public static let contentType: String     = "application/json";
            public static let contentTypeName: String = "Content-Type";
            public static let pollingInterval: UInt64 = 300_000_000; // 300ms
        }

        private let url: URL;

        public init(player: String? = nil, url: URL? = nil) {
            self.player = player ?? ID(veryshort: true).value;
            self.handler = nil;
            self.url = url ?? URL(string: Defaults.url)!
        }

	    fileprivate func register(_ player: String) async -> (player: String, host: String)? {
		    struct Response: Decodable { let player: String ; let host: String };
    	    var request: URLRequest = self.url.request("/register/\(player)", method: "POST");
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
    }

    public class HttpSession_New: GameCenter.Session_New {

        public                  var player: String { self.transport.player };   // Session_New imp
        public fileprivate(set) var host: String = "";                          // Session_New imp
        public                  var hosting: Bool { self.player == self.host }; // Session_New imp
        public                  var players: [String] { [""] };                 // Session_New imp

        private let transport: GameCenter.HttpTransport_New;

        public init(transport: GameCenter.HttpTransport_New) {
            self.transport = transport;
        }
    }

    public class HttpManager_New: GameCenter.Manager_New {

        public var transport: GameCenter.Transport_New { self.transportImp }; // Manager_New imp
        public var session: GameCenter.Session_New { self.sessionImp };       // Manager_New imp

        private var transportImp: HttpTransport_New;
        private var sessionImp: HttpSession_New;

        public init() {
            self.transportImp = HttpTransport_New();
            self.sessionImp = HttpSession_New(transport: self.transportImp);
        }

        public func start() async { // Manager_New imp
            if let response = await self.transportImp.register(self.transport.player) {
                self.sessionImp.host = response.host;
            }
        }

        public func stop() { // Manager_New imp
        }
    }

    public class HttpTransport: Transport {

        public static let instance: HttpTransport = HttpTransport(player: ID(veryshort: true).value);

        public  let player: String;
        public  var host: String = "";
        public var handler: GameCenter.MessageHandler?;
        private let url: URL;
        private var retrievedCount: Int = 0;
        private var sentCount: Int = 0;
        public var hosting: Bool { self.player == self.host }

        public init(player: String, url: URL? = nil) {
            self.player = player;
            self.url = url ?? URL(string: Defaults.url)!
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
                    //
                    // If we are the host, then send the message to all clients;
                    // and also send it to ourself the host, so that we the host
                    // act as much as possible like the clients.
                    //
                    let players: [String] = await self.retrievePlayers();
                    for player in players {
                        self.sendMessage(message: message, to: player);
                    }
                }
                else if (self.host != "") {
                    //
                    // If we are the client (i.e. we are not the host),
                    // then send the message only to the host.
                    //
                    self.sendMessage(message: message, to: self.host);
                }
            }
        }

        public func handle(message: GameCenter.PingMessage) {
            print("DEBUG-\(AID):HANDLE(Ping)> message: \(message.type) player: \(message.player)");
            self.handler?.handle(message: message);
        }

        public func handle(message: GameCenter.PlayerReadyMessage) {
            print("DEBUG-\(AID):HANDLE(PlayerReady)> message: \(message.type) player: \(message.player)");
            self.handler?.handle(message: message);
        }

        public func handle(message: GameCenter.NewGameMessage) {
            print("DEBUG-\(AID):HANDLE(NewGame)> message: \(message.type) player: \(message.player)");
            self.handler?.handle(message: message);
        }

        public func handle(message: GameCenter.FoundSetMessage) {
            print("DEBUG-\(AID):HANDLE(FoundSet)> message: \(message.type) player: \(message.player)");
            self.handler?.handle(message: message);
        }

        public func handle(message: GameCenter.ConfirmedSetMessage) {
            print("DEBUG-\(AID):HANDLE(ConfirmedSet)> message: \(message.type) player: \(message.player)");
            self.handler?.handle(message: message);
        }

        private func sendMessage(message: GameCenter.Message, to player: String? = nil) {
            print("DEBUG-\(AID):SEND> message: \(message.type) player: \(message.player)");
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
            let url: URL = URL(string: "/messagecount/\(player)", relativeTo: self.url)!;
            if let response = try? await URLSession.shared.data(from: url) {
                let data: Data = response.0;
                if let envelope = try? JSONDecoder().decode(MessageEnvelope.self, from: data) {
                    return envelope.count;
                }
            }
            return 0;
        }

        public func retrieveMessageQueuedCountAll() async -> Int {
            struct MessageEnvelope: Decodable { let count: Int }
            let url: URL = URL(string: "/messagecount", relativeTo: self.url)!;
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
                print("DEBUG-\(AID):REGISTER> set-host: \(response.host)")
                self.host = response.host;
            }
        }

	    private func registerPlayer(_ player: String? = nil) async -> (player: String, host: String)? {
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

        public func retrieveHost() async -> String {
            let url: URL = URL(string: "/host", relativeTo: self.url)!;
            if let response = try? await URLSession.shared.data(from: url) {
                let data: Data = response.0;
                if let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let host = object["host"] as? String {
                    return host;
                }
            }
            return "";
        }

		public func reset() async -> Bool {
            let url: URL = URL(string: "/reset", relativeTo: self.url)!;
    		var request = URLRequest(url: url);
    		request.httpMethod = "POST";
            if let response = try? await URLSession.shared.data(for: request) {
                let data: Data = response.0;
        		if let response = response.1 as? HTTPURLResponse, response.statusCode == 200 {
        		    let result = String(data: data, encoding: .utf8);
                    return true;
                }
            }
            return false;
		}

		public func resetMessages(player: String? = nil) async -> Bool {
            // Clears out all messages for given (or this) player on the server.
            let url: URL = URL(string: "/resetmessages/\(player)", relativeTo: self.url)!;
    		var request = URLRequest(url: url);
    		request.httpMethod = "POST";
            if let response = try? await URLSession.shared.data(for: request) {
                let data: Data = response.0;
        		if let response = response.1 as? HTTPURLResponse, response.statusCode == 200 {
        		    let result = String(data: data, encoding: .utf8);
                    self.sentCount = 0;
                    self.retrievedCount = 0;
                    return true;
                }
            }
            return false;
		}

		public func resetMessagesAll() async -> Bool {
            // Clears out ALL messages on the server.
            let url: URL = URL(string: "/resetmessages", relativeTo: self.url)!;
    		var request = URLRequest(url: url);
    		request.httpMethod = "POST";
            if let response = try? await URLSession.shared.data(for: request) {
                let data: Data = response.0;
        		if let response = response.1 as? HTTPURLResponse, response.statusCode == 200 {
        		    let result = String(data: data, encoding: .utf8);
                    self.sentCount = 0;
                    self.retrievedCount = 0;
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
                    print("DEBUG-\(AID):RESET-HOST> set-host: \(self.host) -> unset")
                    self.host = "";
                    return true;
                }
            }
            return false;
		}

		public func unsetHost(host: String? = nil) async -> Bool {
            let host: String = host ?? self.player;
            let url: URL = URL(string: "/nohost/\(host)", relativeTo: self.url)!;
    		var request = URLRequest(url: url);
    		request.httpMethod = "POST";
            if let response = try? await URLSession.shared.data(for: request) {
                let data: Data = response.0;
        		if let response = response.1 as? HTTPURLResponse, response.statusCode == 200 {
        		    let result = String(data: data, encoding: .utf8);
                    print("DEBUG-\(AID):SET-HOST> set-host: \(self.host) -> \(host)")
                    self.host = host;
                    return true;
                }
            }
            return false;
		}

		public func setHost(host: String? = nil) async -> Bool {
            let host: String = host ?? self.player;
            let url: URL = URL(string: "/host/\(host)", relativeTo: self.url)!;
    		var request = URLRequest(url: url);
    		request.httpMethod = "POST";
            if let response = try? await URLSession.shared.data(for: request) {
                let data: Data = response.0;
        		if let response = response.1 as? HTTPURLResponse, response.statusCode == 200 {
        		    let result = String(data: data, encoding: .utf8);
                    print("DEBUG-\(AID):SET-HOST> set-host: \(self.host) -> \(host)")
                    self.host = host;
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
                    if (messages.count > 0) { print("DEBUG-\(AID):POLL> messages: \(messages.count)"); }
                    self.dispatchMessages(messages: messages);
                    //
                    // Also BTW check that the host has not changed out from under
                    // us as could happen with our test/debug/development panel.
                    //
                    self.host = await self.retrieveHost();
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
