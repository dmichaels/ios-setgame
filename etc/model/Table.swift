public class Table: SessionHandler {

    // SessionHandler protocol implementation.

    public var session: Session?

    // MessageHandler protocol implementation.

    public func handle(message: PingMessage) {
    }

    // Table class implementation.

    public func startNewGame() {
        if let session: Session = self.session {
            session.send(message: PingMessage(), to: session.player);
        }
    }
}
