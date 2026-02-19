import Foundation

public extension MultiPlayer {

    public class HttpTransport: Transport {

        public typealias Factory = (MessageHandler) -> HttpTransport;

        // Transport protocol implementation.

        public private(set) var player: String = ID(veryshort: true).value

        public func engage() {
            guard self.pollTask == nil else { return }
            self.pollTask = Task {
                while (!Task.isCancelled) {
                    let messages: [Message] = await self.retrieveMessages(for: self.player, session: self.pollSession);
                    self.dispatchMessages(messages: messages);
                    try? await Task.sleep(nanoseconds: self.pollInterval);
                }
            }
        }

        public func disengage() {
            self.pollTask?.cancel();
            self.pollTask = nil;
        }

        // Bind this HttpTransport to the given session ID; and note
        // this includes naturally the session ID for message polling.
        //
        public func bind(to session: String) {
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
        public func bindTentative(to session: String) {
            self.pollSession = session;
        }

        // Creates a new session on the server with its initial player,
        // and its host, as the given player; returns the new session ID.
        //
        public func create(host player: String, bind: Bool = false) async -> String? {
            if let session: Json = await self.url.post("/sessions", player, as: Json.self, key: self.key) {
                if let session: String = session["session"] as? String {
                    if (bind) {
                        self.bind(to: session);
                    }
                    return session;
                }
            }
            return nil;
        }

        public func register(player: String, session: String? = nil) async -> (player: String, host: String)? {
            if let session: String = session ?? self.session {
                if let response: Json = await self.url.post(session, "/register_and_notify", player, as: Json.self, key: self.key) {
                    if let player: String = response["player"] as? String,
                        let host: String = response["host"] as? String {
                        return (player: player, host: host);
                    }
                }
            }
            return nil;
        }

        public func unregister(player: String, session: String? = nil) async -> Bool {
            if let session: String = session ?? self.session {
                if let response: Json = await self.url.post(session, "/unregister_and_notify", player, as: Json.self, key: self.key) {
                    return true;
                }
            }
            return false;
        }

        public func requestHost(player: String, session: String? = nil) async -> Bool {
            if let session: String = session ?? self.session {
                if let response: Json = await self.url.post(session, "/host_and_notify", player, as: Json.self, key: self.key) {
                    return true;
                }
            }
            return false;
        }

        public func destroySession(session: String? = nil) async -> Bool {
            if let session: String = session ?? self.session {
                if let response: Json = await self.url.post("/sessions", session, "/destroy", as: Json.self, key: self.key) {
                    self.disengage();
                    return true;
                }
            }
            return false;
        }

        // Sends the given message to the given player for the session.
        //
        public func send(message: Message, player: String, session: String? = nil) async -> Bool {
            deb("HttpTransport.send(\(message.type)> player: \(player) session: \(session)")
            return await self.postMessage(path: "/send/\(player)", message: message, session: session);
        }

        // Sends the given message to the HOST for the session via POST /<session>/send;
        // in contrast to sending a message to ANY player via POST /<session>/send/player.
        //
        public func sendHost(message: Message, session: String? = nil) async -> Bool {
            return await self.postMessage(path: "/send", message: message, session: session);
        }

        // HttpTransport class implementation.

        private let handler: MessageHandler;
        private var url: URL;
        private let urlProduction: URL;
        private let urlDevelopment: URL;
        private let key: String;
        private var session: String?;
        private var pollSession: String?;
        private var pollTask: Task<Void, Never>? = nil;
        private let pollInterval: UInt64 = 500_000_000;

        public init(handler: MessageHandler, url: String? = nil, urlDevelopment: String? = nil,  key: String? = nil) {
            self.handler = handler;
            let urlProduction: URL = (url != nil) ? URL.create(url!) : URL.create("http://127.0.0.1:8001");
            let urlDevelopment: URL = (urlDevelopment != nil) ? URL.create(urlDevelopment!) : urlProduction;
            let url: URL = urlProduction;
            self.urlProduction = urlProduction;
            self.urlDevelopment = urlDevelopment;
            self.url = url;
            self.key = key ?? ".0turangalila";
        }

        private func retrieveMessages(for player: String? = nil, session: String? = nil) async -> [Message] {
            if let session: String = session ?? self.session {
                let player: String = player ?? self.player;
                if let data: Data = await self.url.get(session, "/receive", player, key: self.key) {
                    if let messages: [Message] = MessageConversion.toMessages(data: data) {
                        if messages.count > 0 { for message in messages { deb("MESSAGE RECEIVED: \(message.type)") } }
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

        private func dispatchMessages(messages: [Message]) {
            DispatchQueue.main.async {
                MessageConveyance.dispatch(messages: messages, handler: self.handler);
            }
        }

        // These are for internal dev/testing/debugging (DevPanel) usage only!

        public func sessions() async -> [String]? {
            if let sessions: [String] = await self.url.get("/sessions", as: [String].self, key: self.key) {
                return sessions;
            }
            return nil;
        }

        public func session(_ session: String?) async -> Json? {
            if let session: String = session ?? self.session {
                if let response: Json = await self.url.get("/sessions", session, as: Json.self, key: self.key) {
                    return response;
                }
            }
            return nil;
        }

        public static func messageCounts(info: Json, player: String) -> (sent: Int, queued: Int, received: Int) {
            var sent: Int = 0; var queued: Int = 0; var received: Int = 0;
            if let count: Json = info["sent_count"] as? Json, let count = count[player] as? Int {
                sent = count;
            }
            if let count: Json = info["queued_count"] as? Json, let count = count[player] as? Int {
                queued = count;
            }
            if let count: Json = info["received_count"] as? Json, let count = count[player] as? Int {
                received = count;
            }
            return (sent: sent, queued: queued, received: received);
        }

        public struct MessageReceived: Identifiable {
            public let id: UUID = UUID();
            public var timestamp: String;
            public var to: String;
            public var host: String;
            public var players: [String];
            public var message: Message;
        }

        public static func messagesReceived(info: Json, player: String) -> [MessageReceived]? {
            var result: [MessageReceived] = [];
            if let messagesInfo: [Json] = info["received_messages"] as? [Json] {
                for messageInfo: Json in messagesInfo {
                    if let messagesItem: Json = messageInfo[player] as? Json {
                        if let timestamp: String = messagesItem["timestamp"] as? String,
                           let to: String = messagesItem["to"] as? String,
                           let host: String = messagesItem["host"] as? String,
                           let players: [String] = messagesItem["players"] as? [String],
                           let messages: [Json] = messagesItem["messages"] as? [Json] {
                            for message in messages {
                                if let message = MessageConversion.toMessage(json: message) {
                                    //
                                    // Note that the timestamp value from our little Python
                                    // server looks like this: "2026-02-18T18:56:31.446055+00:00";
                                    // we do not bother with conversion to/from Date type; only
                                    // interested in the time: hour, minute, second, milliseconds.
                                    //
                                    result.append(MessageReceived(
                                        timestamp: timestamp.substring(from: 11, length: 12),
                                        to: to,
                                        host: host,
                                        players: players,
                                        message: message));
                                }
                            }
                        }
                    }
                }
                return result;
            }
            return nil;
        }

        public static func messagesReceivedByTimestamp(info: Json, reversed: Bool = false) -> [MessageReceived]? {
            var result: [MessageReceived] = [];
            if let messagesInfo: [Json] = info["received_messages"] as? [Json] {
                for messageInfo: Json in messagesInfo {
                    for (player, messagesItem): (String, Any) in messageInfo {
                        if let messagesItem: Json = messagesItem as? Json {
                            if let timestamp: String = messagesItem["timestamp"] as? String,
                               let to: String = messagesItem["to"] as? String,
                               let host: String = messagesItem["host"] as? String,
                               let players: [String] = messagesItem["players"] as? [String],
                               let messages: [Json] = messagesItem["messages"] as? [Json] {
                                for message in messages {
                                    if let message = MessageConversion.toMessage(json: message) {
                                        result.append(MessageReceived(
                                            timestamp: timestamp.substring(from: 11, length: 12),
                                            to: to,
                                            host: host,
                                            players: players,
                                            message: message));
                                    }
                                }
                            }
                        }
                    }
                }
                return result.sorted { reversed ? $0.timestamp > $1.timestamp : $0.timestamp < $1.timestamp };
            }
            return nil;
        }

        public var engaged: Bool { self.pollTask != nil }

        public var server: String {
            if let host: String = self.url.host {
                if let port: Int = self.url.port {
                    return "\(host):\(port)";
                }
                else {
                    return host;
                }
            }
            return "server";
        }

        public var production: Bool {
            get {
                return self.url.value == self.urlProduction.value;
            }
            set {
                if (newValue) {
                    self.url = self.urlProduction;
                }
                else {
                    self.url = self.urlDevelopment;
                }
            }
        }

        public func debug(enable: Bool?) async -> Bool {
            if let enable: Bool = enable {
                await self.url.post(enable ? "/debug" : "/nodebug", as: Json.self, key: self.key);
            }
            if let response: Json = await self.url.get("/debug", as: Json.self, key: self.key) {
                if let debug: Bool = response["debug"] as? Bool, debug {
                    return true;
                }
            }
            return false;
        }

        public func ping() async -> Bool {
            if let response: Json = await self.url.get("/ping", as: Json.self, key: self.key) {
                if let status: String = response["status"] as? String, status == "OK" {
                    return true;
                }
            }
            return false;
        }
    }
}
