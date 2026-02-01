public extension XGameCenter
{
    public class HttpTransport: XGameCenter.Transport {
        public var  handler: XGameCenter.MessageHandler?
        public var  player: String = "A";
        public func start() {}
        public func stop() {}
        public func send(message: XGameCenter.Message) {}
        public func handle(message: XGameCenter.PingMessage) {}
        public func bind(to handler: XTable) {
            self.handler = handler;
            handler.sender = self;
        }
    }
}
