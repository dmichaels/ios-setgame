import Foundation

public protocol MultiPlayerReceiver: AnyObject {
    func receive(message: Data, from senderID: String);
}

public protocol MultiPlayerTransport {
    func send(message: Data, to recipientID: String);
    func startReceiving();
    func stopReceiving();
}

public class RelayTransport: MultiPlayerTransport {

    private weak let receiver: MultiPlayerReceiver?;
    private      let player: String;
    private      let url: URL;
    private      var pollingTimer: Timer?;

    public init(player: String, receiver: MultiPlayerReceiver?, url: URL? = nil) {
        self.player = player
        self.receiver = receiver
        self.url = url ?? URL("http://127.0.0.1:5000")!
    }

    public func send(message: Data, to recipientID: String) {
        let url = url.appendingPathComponent("POST")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let base64Data = message.base64EncodedString()
        let json: [String: Any] = [
            "to": recipientID,
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
                        self.receiver?.receive(message: decoded, from: from)
                    }
                }
            }
        }.resume()
    }
}
