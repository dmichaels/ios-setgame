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
        private var pollTask: Task<Void, Never>? = nil;
        private let pollInterval: UInt64 = 1_000_000_000;

        public init(handler: MessageHandler, url: URL? = nil) {
            self.handler = handler;
            self.url = url ?? URL.create("https://api.logicard.dmichaels.dev");
            print("HTTP-TRANSPORT CREATED> url: \(self.url.value)")
            self.key = ".0turangalila";
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

        public func registerPlayerAndSend(_ player: String, message: Message, session: String? = nil) async -> (player: String, host: String)? {
            if let session: String = session ?? self.session {
                if let message: Json = message.json {
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

        // Sends the given message to the given player for the session.
        //
        public func sendMessage(_ message: Message, player: String, session: String? = nil) async -> Bool {
            if let message: Json = message.json, let session: String = session ?? self.session {
                if let response: Json = await self.url.post(session, "/send", player, data: message, as: Json.self, key: self.key) {
                    if let status: String = response["status"] as? String, status == "OK" {
                        return true;
                    }
                }
            }
            return false;
        }

        // Sends the given message to the HOST for the session via POST /<session>/send;
        // in contrast to sending a message to ANY player via POST /<session>/send/player.
        //
        public func sendHostMessage(_ message: Message, session: String? = nil) async -> Bool {
            if let message: [String: Any] = message.json, let session: String = session ?? self.session {
                if let response: Json = await self.url.post(session, "/send", data: message, as: Json.self, key: self.key) {
                    if let status: String = response["status"] as? String, status == "OK" {
                        return true;
                    }
                }
            }
            return false;
        }

        // Sends the given message to the given player for the session.
        // This is a NON-async version of the above for possible convenience;
        // since it is just a send and we do not really need to get/check the result.
        //
        public func sendMessage(_ message: Message, player: String, session: String? = nil) -> Bool{
            if let message: Json = message.json, let session: String = session ?? self.session {
                if (self.url.post([session, "/send", player], data: message, key: self.key)) {
                    return true;
                }
            }
            return false;
        }

        // Sends the given message to the HOST for the session via POST /<session>/send;
        // in contrast to sending a message to ANY player via POST /<session>/send/player.
        // This is a NON-async version of the above for possible convenience;
        // since it is just a send and we do not really need to get/check the result.
        //
        public func sendHostMessage(_ message: Message, session: String? = nil) -> Bool {
            if let message: [String: Any] = message.json, let session: String = session ?? self.session {
                if (self.url.post(session, "/send", data: message, key: self.key)) {
                    return true;
                }
            }
            return false;
        }

        public func retrieveMessages(for player: String? = nil, session: String? = nil) async -> [Message] {
            // print("RETRIEVE-MESSAGES> player: \(player) session: \(session)");
            if let session: String = session ?? self.session {
                print("POLLING MESSAGES> player: \(player) session: \(session) self.session: \(self.session)");
                // print("RETRIEVE-MESSAGES-2> player: \(player) session: \(session)");
                let player: String = player ?? self.player;
                if let data: Data = await self.url.get(session, "receive", player, key: self.key) {
                    // print("RETRIEVE-MESSAGES-3> player: \(player) session: \(session)");
                    if let messages: [Message] = MessageConversion.toMessages(data: data) {
                        if messages.count > 0 {
                            print("POLLED MESSAGES> player: \(player) session: \(session) count: \(messages.count) messages: \(messages)");
                        }
                        return messages; 
                    }
                }
            }
            else {
                print("NOT POLLING MESSAGES> player: \(player) session: \(session) self.session: \(self.session)");
            }
            return [];
        }

        private func poll() {
            print("START MESSAGE POLLING> player: \(self.player) session: \(self.session)")
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
            print("STOP MESSAGE POLLING> player: \(self.player) session: \(self.session)")
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
