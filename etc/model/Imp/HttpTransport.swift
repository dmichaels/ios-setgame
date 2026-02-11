import Foundation

public class HttpTransport: Transport {

    // Transport protocol implementation.

    public var player: String = ID(veryshort: true).value

    public func setup() {
        self.poll();
    }

    public func release() {
        self.nopoll();
    }

    // MessageHandler (via Transport) protocol implementation.

    public func handle(message: PingMessage) {
    }

    public func handle(message: JoinSessionMessage) {
    }

    public func handle(message: JoinedSessionMessage) {
    }

    // HttpTransport class implementation.

    private var handler: MessageHandler;
    private let url: URL;
    private let key: String;
    private var session: String?;
    private var pollTask: Task<Void, Never>? = nil;
    private let pollInterval: UInt64 = 1_000_000_000;

    public init(handler: MessageHandler) {
        print("HTTP-TRANSPORT.INIT")
        self.handler = handler;
        self.url = URL.create("https://api.logicard.dmichaels.dev");
     // self.url = URL.create("http://127.0.0.1:8001");
        self.key = ".0turangalila";
        Task {
            if let x: [String] = await self.url.get("/sessions", as: [String].self, key: ".0turangalila") {
                print("SESSIONS FROM SERVER: \(x)")
            }
            else {
                print("SESSIONS FROM SERVER ERROR!")
            }
        }
    }

    public func createSession(bind: Bool = false) async -> String? {
        if let session: Json = await self.url.post("/sessions", as: Json.self, key: self.key) {
            if let session: String = session["session"] as? String {
                if (bind) {
                    self.session = session;
                }
                return session;
            }
        }
        return nil;
    }

    public func createAndHostSession(host player: String, bind: Bool = false) async -> String? {
        if let session: Json = await self.url.post("/sessions", player, as: Json.self, key: self.key) {
            if let session: String = session["session"] as? String {
                if (bind) {
                    self.session = session;
                }
                return session;
            }
        }
        return nil;
    }

    public func registerPlayer(_ player: String, session: String? = nil) async -> (player: String, host: String)? {
        if let session: String = session ?? self.session {
            if let response: Json = await self.url.post(session, "/register", player, as: Json.self, key: self.key) {
                if let player: String = response["player"] as? String,
                    let host: String = response["host"] as? String {
                    return (player: player, host: host);
                }
            }
        }
        return nil;
    }

    public func registerPlayerAndSendNew(_ player: String, message: Message, session: String? = nil) async -> (player: String, host: String)? {
        if let session: String = session ?? self.session {
            if let message: [String: Any] = message.json {
                if let response: Json = await self.url.post(session, "/register_and_send", player, as: Json.self, key: self.key) {
                    if let player: String = response["player"] as? String,
                        let host: String = response["host"] as? String {
                        return (player: player, host: host);
                    }
                }
            }
        }
        return nil;
    }

    public func sendMessage(_ message: Message, session: String? = nil) -> Bool {
        if let message: [String: Any] = message.json,
           let session: String = session ?? self.session {
            if (self.url.post(session, "/send", data: message, key: self.key)) {
                return true;
            }
        }
        return false;
    }

    public func retrieveMessages(for player: String? = nil, session: String? = nil) async -> [Message] {
        print("RETRIEVE-MESSAGES> player: \(player) session: \(session)");
        if let session: String = session ?? self.session {
            print("RETRIEVE-MESSAGES-2> player: \(player) session: \(session)");
            let player: String = player ?? self.player;
            if let data: Data = await self.url.get(session, "receive", player, key: self.key) {
                print("RETRIEVE-MESSAGES-3> player: \(player) session: \(session)");
                if let messages: [Message] = MessageConversion.toMessages(data: data) {
                    print("RETRIEVE-MESSAGES-4> player: \(player) session: \(session) messages: \(messages)");
                    return messages; 
                }
            }
        }
        return [];
    }

    private func poll() {
        print("TRANSPORT.POLL")
        guard self.pollTask == nil else { return }
        self.pollTask = Task {
            while (!Task.isCancelled) {
                let messages: [Message] = await self.retrieveMessages(for: self.player);
                self.dispatchMessages(messages: messages);
                try? await Task.sleep(nanoseconds: self.pollInterval);
            }
        }
    }

    private func nopoll() {
        print("TRANSPORT.NOPOLL")
        // self.pollTask?.cancel();
        // self.pollTask = nil;
    }

    private func dispatchMessages(messages: [Message]) {
        DispatchQueue.main.async {
            MessageConveyance.dispatch(messages: messages, handler: self);
        }
    }
}
