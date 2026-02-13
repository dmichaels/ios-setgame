public extension GameCenter {

    public protocol MessageHandler: AnyObject {
        func handle(message: PingMessage);
        func handle(message: JoinSessionMessage);
        func handle(message: JoinedSessionMessage);
        func handle(message: LeaveSessionMessage);
        func handle(message: UpdateSessionMessage);
    }
}
