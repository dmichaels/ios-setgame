import Foundation

extension GameCenter
{
    protocol Transport: GameCenter.MessageSender, GameCenter.MessageHandler {
        func configure(handler: MessageHandler);
    }
}

extension GameCenter
{
    public class HttpTransport: Transport {

        private let player: String;
        private var handler: GameCenter.MessageHandler?;
        private let url: URL;

        public init(player: String, handler: GameCenter.MessageHandler? = nil, url: URL? = nil) {
            self.player = player;
            self.handler = handler;
            self.url = url ?? URL(string: Defaults.url)!
            print("HttpTransport.init> id: \(ObjectIdentifier(self))");
        }

        public func configure(handler: GameCenter.MessageHandler) {
            self.handler = handler;
            self.startPolling();
            print("HttpTransport.configure> id: \(ObjectIdentifier(self)) handler: \(self.handler != nil)");
        }

        private struct Defaults {
            public static let url: String             = "http://127.0.0.1:5000";
            public static let contentType: String     = "application/json";
            public static let contentTypeName: String = "Content-Type";
            public static let pollingInterval: UInt64 = 2_000_000_000; // 2s // 100_000_000; // 100s
        }

        private var pollingTask: Task<Void, Never>? = nil;

        public func send(message: GameCenter.PlayerReadyMessage) {
            print("HttpTransport.send(PlayerReady)> \(message) id: \(ObjectIdentifier(self)) handler: \(self.handler != nil)");
            self.sendMessage(message: message);
        }

        public func send(message: GameCenter.DealCardsMessage) {
            print("HttpTransport.send(DealCards)> \(message) id: \(ObjectIdentifier(self)) handler: \(self.handler != nil)");
            self.sendMessage(message: message);
        }

        public func send(message: GameCenter.FoundSetMessage) {
            print("HttpTransport.send(FoundSet)> \(message) id: \(ObjectIdentifier(self)) handler: \(self.handler != nil)");
            self.sendMessage(message: message);
        }

        public func handle(message: GameCenter.PlayerReadyMessage) {
            print("HttpTransport.handle(PlayerReady)> \(message) id: \(ObjectIdentifier(self)) handler: \(self.handler != nil)");
            self.handler?.handle(message: message);
        }

        public func handle(message: GameCenter.DealCardsMessage) {
            print("HttpTransport.handle(DealCards)> \(message) id: \(ObjectIdentifier(self)) handler: \(self.handler != nil)");
            self.handler?.handle(message: message);
        }

        public func handle(message: GameCenter.FoundSetMessage) {
            print("HttpTransport.handle(FoundSet)> \(message) id: \(ObjectIdentifier(self)) handler: \(self.handler != nil)");
            self.handler?.handle(message: message);
        }

        private func sendMessage(message: GameCenter.Message) {
            self.sendMessage(data: message.serialize(), to: message.player);
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
            }
        }

        public func retrieveMessages(for player: String) async -> [GameCenter.Message] {
            let url: URL = URL(string: "/receive/\(player)", relativeTo: self.url)!;
            if let response = try? await URLSession.shared.data(from: url) {
                let data: Data = response.0;
                if let messages: [GameCenter.Message] = GameCenter.toMessages(data: data) {
                    return messages;
                }
            }
            return [];
        }

        private func startPolling() {
            print("HttpTransport.startpolling> id: \(ObjectIdentifier(self)) handler: \(self.handler != nil)");
            guard self.pollingTask == nil else { return }
            print("HttpTransport.startpolling.2> id: \(ObjectIdentifier(self)) handler: \(self.handler != nil)");
            self.pollingTask = Task {
                print("HttpTransport.startpolling.3> id: \(ObjectIdentifier(self)) handler: \(self.handler != nil)");
                while (!Task.isCancelled) {
                    print("HttpTransport.startpolling.4> id: \(ObjectIdentifier(self)) handler: \(self.handler != nil)");
                    let messages = await self.retrieveMessages(for: player)
                    print("HttpTransport.startpolling.5> id: \(ObjectIdentifier(self)) handler: \(self.handler != nil)");
                    GameCenter.dispatch(messages: messages, handler: self);
                    try? await Task.sleep(nanoseconds: Defaults.pollingInterval);
                    print("HttpTransport.startpolling.6> id: \(ObjectIdentifier(self)) handler: \(self.handler != nil)");
                }
            }
        }

        private func stopPolling() {
            pollingTask?.cancel();
            pollingTask = nil;
        }
    }
}
