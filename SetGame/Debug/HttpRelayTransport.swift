import Foundation

public protocol MultiPlayerHandler: AnyObject {
    func handle(message: GameCenter.PlayerReadyMessage);
    func handle(message: GameCenter.DealCardsMessage);
    func handle(message: GameCenter.FoundSetMessage);
}

public protocol MultiPlayerSender: AnyObject {
    func send(message: GameCenter.PlayerReadyMessage);
    func send(message: GameCenter.DealCardsMessage);
    func send(message: GameCenter.FoundSetMessage);
}

public protocol MultiPlayerTransport: MultiPlayerSender {
    func send(message: Data, to player: String);
    func startHandler();
    func stopReceiving();
}

public class RelayTransport /* MultiPlayerTransport*/ {

    func receive(message: Data, from player: String) {}
    func playerReady(message: GameCenter.PlayerReadyMessage) {}
    func dealCards(message: GameCenter.DealCardsMessage) {}
    func foundSet(message: GameCenter.FoundSetMessage) {}

    func sendPlayerReady(message: GameCenter.PlayerReadyMessage) {}
    func sendDealCards(message: GameCenter.DealCardsMessage) {}
    func sendFoundSet(message: GameCenter.FoundSetMessage) {}

    private weak let handler: MultiPlayerHandler?;
    private      let player: String;
    private      let url: URL;
    private      var pollingTimer: Timer?;

    public init(player: String, handler: MultiPlayerHandler? = nil, url: URL? = nil) {
        self.player = player
        self.handler = handler
        self.url = url ?? URL("http://127.0.0.1:5000")!
    }

    public func send(message: Data, to player: String) {
        let url = url.appendingPathComponent("POST")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let base64Data = message.base64EncodedString()
        let json: [String: Any] = [
            "to": player,
            "data": base64Data
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: json)
        URLSession.shared.dataTask(with: request).resume()
    }

    public func startReceiving() {
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.pollForMessages()
        }
    }

    public func stopReceiving() {
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
                        // TODO self.receiver?.receive(message: decoded, from: from)
                    }
                }
            }
        }.resume()
    }
}
