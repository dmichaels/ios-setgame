public class TableCard {
    public init(_: String) {
    }
}

public class Table: GameCenter.SessionHandler {

    // SessionHandler protocol implementation.

    public var session: GameCenter.Session?

    // MessageHandler (via SessionHandler) protocol implementation.

    public func handle(message: GameCenter.PingMessage) {}

    // Table class implementation.

    public func startNewGame() {
        if let session: GameCenter.Session = self.session {
            session.send(message: GameCenter.PingMessage(), to: session.player);
        }
    }
}
