public extension GameCenter {

    public protocol MessageHandler: AnyObject {
        func handle(message: PingMessage);
        func handle(message: JoinSessionMessage);
        func handle(message: JoinSessionConfirmedMessage);
        func handle(message: LeaveSessionMessage);
        func handle(message: UpdateSessionMessage);
    }
}
