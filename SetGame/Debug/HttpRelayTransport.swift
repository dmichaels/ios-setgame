import Foundation

extension GameCenter
{
    protocol Transport: GameCenter.MessageSender, GameCenter.MessageHandler {
        func setHandler(_ handler: MessageHandler);
        func initialize();
    }
}

extension GameCenter
{
    public class HttpTransport: Transport { // GameCenter.MessageSender, GameCenter.MessageHandler {

        private      let player: String;
        private weak var handler: MessageHandler?;
        private      let url: URL;

        public init(player: String, handler: MessageHandler? = nil, url: URL? = nil) {
            self.player = player;
            self.handler = handler;
            self.url = url ?? URL(string: Defaults.url)!
        }

        public func setHandler(_ handler: MessageHandler) {
            self.handler = handler;
        }

        private struct Defaults {
            public static let url: String             = "http://127.0.0.1:5000";
            public static let contentType: String     = "application/json";
            public static let contentTypeName: String = "Content-Type";
        }

        private var pollingTask: Task<Void, Never>? = nil
        private var pollingInterval: UInt64 = 300_000_000; // 100ms

        public func send(message: GameCenter.PlayerReadyMessage) {
        }

        public func send(message: GameCenter.DealCardsMessage) {
        }

        public func send(message: GameCenter.FoundSetMessage) {
        }

        public func handle(message: Data, from player: String) {
        }

        public func handle(message: GameCenter.PlayerReadyMessage) {
        }

        public func handle(message: GameCenter.DealCardsMessage) {
        }

        public func handle(message: GameCenter.FoundSetMessage) {
        }

        public func sendMessage(message: GameCenter.Message) {
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
            let (data, _) = try! await URLSession.shared.data(from: url);
            if let messages: [GameCenter.Message] = GameCenter.toMessages(data: data) {
                return messages;
            }
            return [];
        }

        public func initialize() {
            self.startPolling();
        }

        public func startPolling() {
            guard pollingTask == nil else { return }
            pollingTask = Task {
                while !Task.isCancelled {
                    let messages = await self.retrieveMessages(for: player)
                    print("POLL-FOR-MESSAGES> messages (\(messages.count)): \(messages)")
                    try? await Task.sleep(nanoseconds: pollingInterval);
                }
            }
        }

        public func stopPolling() {
            pollingTask?.cancel();
            pollingTask = nil;
        }
    }
}
