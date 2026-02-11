public class Table: SessionHandler {

    // SessionHandler protocol implementation.

    public var session: Session?

    // MessageHandler (via SessionHandler) protocol implementation.

    public func handle(message: PingMessage) {}
    public func handle(message: JoinSessionMessage) {}
    public func handle(message: JoinedSessionMessage) {}

    // Table class implementation.

    public func startNewGame() {
        if let session: Session = self.session {
            session.send(message: PingMessage(), to: session.player);
        }
    }
}
