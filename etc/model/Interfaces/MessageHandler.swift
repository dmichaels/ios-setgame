public extension GameCenter {

    public protocol MessageHandler: AnyObject {
        func handle(message: PingMessage);
        func handle(message: JoinSessionMessage);
        func handle(message: JoinedSessionMessage);
        func handle(message: UpdateSessionMessage);
    }
}

public extension GameCenter.MessageHandler {
    //
    // These player joining related message handlers are defaulted so
    // that the main MessageHandler, i.e. Table in our case, does not have
    // to bother implementing these, since this should be of no concern there;
    // these are instead handled directly by the Session implementation.
    //
    func handle(message: GameCenter.PingMessage) {}
    func handle(message: GameCenter.JoinSessionMessage) {}
    func handle(message: GameCenter.JoinedSessionMessage) {}
    func handle(message: GameCenter.UpdateSessionMessage) {}
}
