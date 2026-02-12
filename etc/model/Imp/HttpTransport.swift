import Foundation

public extension GameCenter {

    public class HttpTransport: Transport {

        public typealias Factory = (GameCenter.MessageHandler) -> HttpTransport;

        // Transport protocol implementation.

        public var player: String = ID(veryshort: true).value

        public func setup() {
            self.poll();
        }

        public func release() {
            self.nopoll();
        }

        // HttpTransport class implementation.

        private let handler: MessageHandler;
        private let url: URL;
        private let key: String;
        private var session: String?;
        private var pollSession: String?;
        private var pollTask: Task<Void, Never>? = nil;
        private let pollInterval: UInt64 = 2_000_000_000;

        public init(handler: MessageHandler, url: URL? = nil) {
            self.handler = handler;
            self.url = url ?? URL.create("https://api.logicard.dmichaels.dev");
            self.key = ".0turangalila";
        }

        // Creates a new session on the server with its initial player,
        // and its host, as the given player; returns the new session ID.
        //
        public func createAndHostSession(host player: String, bind: Bool = false) async -> String? {
            if let session: Json = await self.url.post("/sessions", player, as: Json.self, key: self.key) {
                if let session: String = session["session"] as? String {
                    if (bind) {
                        self.bindSession(to: session);
                    }
                    return session;
                }
            }
            return nil;
        }

        // Bind this HttpTransport to the given session ID; and this
        // includes naturally includes the session ID for message polling.
        //
        public func bindSession(to session: String) {
            self.session = session;
            self.pollSession = session;
        }

        // Bind this HttpTransport to the given session ID only for message polling.
        // This is done when we (as a non-host player) have sent to the host a request
        // to join its session; we (as a non-host player) do not fully bind to the host
        // session since we need to wait for a message from the host accepting the session
        // joining request, but to even receive such a message we need to be polling for
        // messages on the given session.
        //
        public func bindSessionTentative(to session: String) {
            self.pollSession = session;
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

        public func registerPlayerAndSend(_ player: String, message: Message, session: String? = nil) async -> (player: String, host: String)? {
            if let session: String = session ?? self.session {
                if let message: Json = message.json {
                    if let response: Json = await self.url.post([session, "/register_and_send", player], data: message, as: Json.self, key: self.key) {
                        if let player: String = response["player"] as? String,
                            let host: String = response["host"] as? String {
                            return (player: player, host: host);
                        }
                    }
                }
            }
            return nil;
        }

        // Sends the given message to the given player for the session.
        //
        public func sendMessage(_ message: Message, player: String, session: String? = nil) async -> Bool {
            return await self.postMessage(path: "/send/\(player)", message: message, session: session);
        }

        // Sends the given message to the HOST for the session via POST /<session>/send;
        // in contrast to sending a message to ANY player via POST /<session>/send/player.
        //
        public func sendHostMessage(_ message: Message, session: String? = nil) async -> Bool {
            return await self.postMessage(path: "/send", message: message, session: session);
        }

        // Sends the given message to the given player for the session.
        // This is a NON-async version of the above for possible convenience;
        // since it is just a send and we do not really need to get/check the result.
        //
        public func sendMessage(_ message: Message, player: String, session: String? = nil) -> Bool {
            return self.postMessage(path: "/send/\(player)", message: message, session: session);
        }

        // Sends the given message to the HOST for the session via POST /<session>/send;
        // in contrast to sending a message to ANY player via POST /<session>/send/player.
        // This is a NON-async version of the above for possible convenience;
        // since it is just a send and we do not really need to get/check the result.
        //
        public func sendHostMessage(_ message: Message, session: String? = nil) -> Bool {
            return self.postMessage(path: "/send", message: message, session: session);
        }

        public func retrieveMessages(for player: String? = nil, session: String? = nil) async -> [Message] {
            if let session: String = session ?? self.session {
                let player: String = player ?? self.player;
                if let data: Data = await self.url.get(session, "receive", player, key: self.key) {
                    if let messages: [Message] = MessageConversion.toMessages(data: data) {
                        if messages.count > 0 { print("RECEIEVED MESSAGES> session: \(session) player: \(player) messages: \(messages.count) -> \(messages)") }
                        return messages; 
                    }
                }
            }
            return [];
        }

        // Sends (POSTs) the given message to the given path for the given or our bound session.
        //
        private func postMessage(path: String, message: Message, session: String? = nil) async -> Bool {
            if let message: Json = message.json, let session: String = session ?? self.session {
                if let response: Json = await self.url.post(session, path, data: message, as: Json.self, key: self.key) {
                    if let status: String = response["status"] as? String, status == "OK" {
                        return true;
                    }
                }
            }
            return false;
        }

        // Sends (POSTs) the given message to the given path for the given or our bound session.
        // This is a NON-async version of the above for possible convenience;
        // since it is just a send and we do not really need to get/check the result.
        //
        private func postMessage(path: String, message: Message, session: String? = nil) -> Bool {
            if let message: Json = message.json, let session: String = session ?? self.session {
                if (self.url.post(session, path, data: message, key: self.key)) {
                    return true;
                }
            }
            return false;
        }

        private func poll() {
            guard self.pollTask == nil else { return }
            self.pollTask = Task {
                while (!Task.isCancelled) {
                    let messages: [Message] = await self.retrieveMessages(for: self.player, session: self.pollSession);
                    self.dispatchMessages(messages: messages);
                    try? await Task.sleep(nanoseconds: self.pollInterval);
                }
            }
        }

        private func nopoll() {
            self.pollTask?.cancel();
            self.pollTask = nil;
        }

        private func dispatchMessages(messages: [Message]) {
            DispatchQueue.main.async {
                MessageConveyance.dispatch(messages: messages, handler: self.handler);
            }
        }
    }
}
