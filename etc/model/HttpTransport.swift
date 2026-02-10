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

    // HttpTransport class implementation.

    private var handler: MessageHandler;
    private let url: URL;
    private let key: String;
    private var session: String?;

    public init(handler: MessageHandler) {
        print("HTTP-TRANSPORT.INIT")
        self.handler = handler;
        self.url = URL.create("https://dmichaels.dev/apis/logicard");
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

    public func createSession() async -> String? {
        if let session: Json = await self.url.post("/session", as: Json.self, key: ".0turangalila") {
            if let session: String = session["session"] as? String {
                self.session = session;
                return session;
            }
        }
        return nil;
    }

    private func poll() {
        print("TRANSPORT.POLL")
    }

    private func nopoll() {
        print("TRANSPORT.NOPOLL")
    }
}
