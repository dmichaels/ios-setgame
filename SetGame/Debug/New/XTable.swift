public class XTable: XGameCenter.MessageHandler {
    public var  sender: XGameCenter.MessageSender?                  // MessageHandler imp
    public func handle(message: XGameCenter.PingMessage) {}         // MessageHandler imp
    public func handle(message: XGameCenter.PlayerReadyMessage) {}  // MessageHandler imp
    public func handle(message: XGameCenter.NewGameMessage) {}      // MessageHandler imp
    public func handle(message: XGameCenter.FoundSetMessage) {}     // MessageHandler imp
    public func handle(message: XGameCenter.ConfirmedSetMessage) {} // MessageHandler imp
}

public class XTestApp {
    public init() {
        var table: XTable = XTable();
        var transport: XGameCenter.Transport = XGameCenter.HttpTransport();
        transport.bind(to: table);
    }
}
