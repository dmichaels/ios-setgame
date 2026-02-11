public protocol MessageHandler {
    func handle(message: PingMessage);
    func handle(message: JoinSessionMessage);
}

public extension MessageHandler {
    public func handle(message: JoinSessionMessage) {
        print("HANDLE-JOIN-SESSSION-MESSAGE!!! \(message)")
        HttpSession.instance?.send(message: JoinSessionAcceptedMessage(session: "TODO"));
        message.player
    }
}
