import Foundation

extension GameCenter
{
    public protocol Handler: AnyObject {
        func handle(message: GameCenter.PlayerReadyMessage);
        func handle(message: GameCenter.DealCardsMessage);
        func handle(message: GameCenter.FoundSetMessage);
    }

    public protocol Sender: AnyObject {
        func send(message: GameCenter.PlayerReadyMessage);
        func send(message: GameCenter.DealCardsMessage);
        func send(message: GameCenter.FoundSetMessage);
    }
}

extension GameCenter
{
    public class Transport: GameCenter.Sender, GameCenter.Handler {

        private      let player: String;
        private weak var handler: Handler?;
        private      let url: URL;

        public init(player: String, handler: Handler? = nil, url: URL? = nil) {
            self.player = player;
            self.handler = handler;
            self.url = url ?? URL(string: Defaults.url)!
        }

        public func setHandler(_ handler: Handler) {
            self.handler = handler;
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

        private func send(message: Data, to player: String) {
            let url = url.appendingPathComponent("POST")
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue(Defaults.contentType, forHTTPHeaderField: Defaults.contentTypeName)

            let base64Data = message.base64EncodedString()
            let json: [String: Any] = [
                "to": player,
                "data": base64Data
            ]

            request.httpBody = try? JSONSerialization.data(withJSONObject: json)
            URLSession.shared.dataTask(with: request).resume()
        }

        public func startHandler() {
            pollingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                self.pollForMessages()
            }
        }

        public func stopHandler() {
            pollingTimer?.invalidate()
            pollingTimer = nil
        }

        private func pollForMessages() {
            let url = url.appendingPathComponent("get/\(player)")
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard
                    let data = data,
                    let messages = try? JSONSerialization.jsonObject(with: data) as? [[String: String]]
                else { return }

                for message in messages {
                    if
                        let from = message["from"],
                        let encodedData = message["data"],
                        let decoded = Data(base64Encoded: encodedData)
                    {
                        DispatchQueue.main.async {
                            // TODO self.handler?.handle(message: decoded, from: from)
                        }
                    }
                }
            }.resume()
        }
    }
}
