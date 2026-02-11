public protocol MessageHandler: AnyObject {
    func handle(message: PingMessage);
    func handle(message: JoinSessionMessage);
    func handle(message: JoinedSessionMessage);
}

public extension MessageHandler {
    public func handle(message: JoinSessionMessage) {
        print("HANDLE-JOIN-SESSSION-MESSAGE!!! \(message)")
        HttpSession.instance?.send(message: JoinedSessionMessage(session: "TODO"));
        message.player
    }
}
