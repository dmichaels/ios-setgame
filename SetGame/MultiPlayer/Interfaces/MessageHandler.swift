public extension MultiPlayer {

    public protocol MessageHandler: AnyObject {
        func handle(message: PingMessage);
        func handle(message: PingAcknowledgeMessage);
        func handle(message: JoinSessionMessage);
        func handle(message: JoinSessionConfirmedMessage);
        func handle(message: LeaveSessionMessage);
        func handle(message: RequestHostSessionMessage);
        func handle(message: UpdateSessionMessage);
        func handle(message: NewGameMessage);
        func handle(message: SetFoundMessage);
        func handle(message: SetConfirmedMessage);
        func handle(message: SetMissedMessage);
        func handle(message: ChatMessage);
    }
}
