public extension GameCenter {

    public protocol MessageHandler: AnyObject {
        func handle(message: PingMessage);
        func handle(message: JoinSessionMessage);
        func handle(message: JoinedSessionMessage);
    }
}

public extension GameCenter.MessageHandler {
    //
    // These player joining related message handlers are defaulted so
    // that the main MessageHandler, i.e. Table in our case, does not have
    // to bother implementing these, since this should be of no concern there;
    // these are instead handled directly by the Session implementation.
    //
    func handle(message: GameCenter.PingMessage) { print("DEFAULT-PING-JOIN-SESSION") }
    func handle(message: GameCenter.JoinSessionMessage) { print("DEFAULT-HANDLE-JOIN-SESSION") }
    func handle(message: GameCenter.JoinedSessionMessage) { print("DEFAULT-HANDLE-JOINED-SESSION") }
}
