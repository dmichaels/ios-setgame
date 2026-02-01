public class XTable: XGameCenter.MessageHandler {
    public var  sender: XGameCenter.MessageSender?
    public func handle(message: XGameCenter.PingMessage) {}
    public func handle(message: XGameCenter.PlayerReadyMessage) {}
    public func handle(message: XGameCenter.NewGameMessage) {}
    public func handle(message: XGameCenter.FoundSetMessage) {}
    public func handle(message: XGameCenter.ConfirmedSetMessage) {}
}
