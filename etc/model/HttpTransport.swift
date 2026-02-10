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
        // self.url = URL.create("http://127.0.0.1:8001");
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

    public func createSession(bind: Bool = false) async -> String? {
        if let session: Json = await self.url.post("/session", as: Json.self, key: self.key) {
            if let session: String = session["session"] as? String {
                if (bind) {
                    self.session = session;
                }
                return session;
            }
        }
        return nil;
    }

    public func registerPlayer(_ player: String, session: String? = nil) async -> Bool {
        if let session: String = session ?? self.session {
            if let response: Json = await self.url.post(session, "/register", player, as: Json.self, key: self.key) {
            }
        }
        return true;
    }

    private func poll() {
        print("TRANSPORT.POLL")
    }

    private func nopoll() {
        print("TRANSPORT.NOPOLL")
    }
}
