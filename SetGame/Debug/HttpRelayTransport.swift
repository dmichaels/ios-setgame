import Foundation

extension GameCenter
{
    protocol Transport: GameCenter.MessageSender, GameCenter.MessageHandler {
        func setHandler(_ handler: MessageHandler);
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
            if (pollingTimer == nil) {
                // self.startPolling();
            }
        }

        private struct Defaults {
            public static let url: String             = "http://127.0.0.1:5000";
            public static let contentType: String     = "application/json";
            public static let contentTypeName: String = "Content-Type";
        }

        private var pollingTimer: Timer?;

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

        public func sendMessage(_ message: GameCenter.Message) {
            self.sendMessage(data: message.serialize(), to: message.player);
        }

        private func old_sendMessage(data: Data?, to player: String) {
            guard let data = data else { return }
            let url: URL = URL(string: "/send", relativeTo: self.url)!;
            var request = URLRequest(url: url);
            request.httpMethod = "POST";
            request.setValue(Defaults.contentType, forHTTPHeaderField: Defaults.contentTypeName);
            let payload: Any = try? JSONSerialization.jsonObject(with: data) as Any;
            let json: [String: Any] = [ "to": player, "message": payload ];
            request.httpBody = try? JSONSerialization.data(withJSONObject: json);
            URLSession.shared.dataTask(with: request).resume();
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
                URLSession.shared.dataTask(with: request).resume()
            }
        }

        public func startPolling() {
            pollingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                self.pollForMessages();
            }
        }

        public func stopPolling() {
            pollingTimer?.invalidate();
            pollingTimer = nil;
        }

        private func pollForMessages() {
            let url = url.appendingPathComponent("receive/\(player)")
            print("POLL> [\(url)]");
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data: Data = data {
                    print("POLL> data: [\(data)]");
                    let dataString = String(data: data, encoding: .utf8);
                    print("POLL> dataString: [\(dataString)]");
                    let messages = try? JSONSerialization.jsonObject(with: data) as? [[String: String]];
                    print("POLL> messages: [\(messages)]");
                    // GameCenter.xhandleMessage(data, dealCards: { message in
                    // GameCenter.handleMessage(data, dealCards: { message in
                    // });
                }
                else {
                    print("POLL> nodata data: [\(data)]");
                }
/*
                guard let data = data,
                      let messages = try? JSONSerialization.jsonObject(with: data) as? [[String: String]]
                else {
                    let xyzzy = String(data: data, encoding: .utf8);
                    print("POLL> nodata data: [\(data)] messages: [\(xyzzy)]");
                    return;
                }
                print("POLL> data: \(data)");
                for message in messages {
                    print("POLL> message: \(message)");
                    if let from = message["from"],
                        let encodedData = message["data"],
                        let decoded = Data(base64Encoded: encodedData) {
                        DispatchQueue.main.async {
                            // self.handler?.handle(message: decoded, from: from)
                            GameCenter.handleMessage(decoded, self.handler);
                        }
                    }
                }
*/
            }.resume()
        }
    }
}
