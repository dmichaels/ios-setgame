public class TableCard {
    public init(_: String) {
    }
}

public class Table: MultiPlayer.SessionHandler {

    // SessionHandler protocol implementation.

    public var session: MultiPlayer.Session?

    // MessageHandler (via SessionHandler) protocol implementation.

    public func handle(message: MultiPlayer.PingMessage) {}

    // Table class implementation.

    public func startNewGame() {
        if let session: MultiPlayer.Session = self.session {
            session.send(message: MultiPlayer.PingMessage(), to: session.player);
        }
    }
}
