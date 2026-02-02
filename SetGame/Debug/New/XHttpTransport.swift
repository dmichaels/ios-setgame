import Foundation

public extension XGameCenter
{
    public class HttpTransport: XGameCenter.Transport {

        public var  player: String = ID(veryshort: true).value;    // Transport imp
        public func send(message: Message) {}                      // Transport imp
        public func start() {}                                     // Transport imp
        public func stop() {}                                      // Transport imp

        public var  sender: MessageSender? { get { self } set {} } // MessageHandler imp
        public func handle(message: PingMessage) {}                // MessageHandler imp
        public func handle(message: PlayerReadyMessage) {}         // MessageHandler imp
        public func handle(message: NewGameMessage) {}             // MessageHandler imp
        public func handle(message: FoundSetMessage) {}            // MessageHandler imp
        public func handle(message: ConfirmedSetMessage) {}        // MessageHandler imp

        private var  handler: XGameCenter.MessageHandler?

        public func bind(to handler: XGameCenter.MessageHandler) {
            self.handler = handler;
            handler.sender = self;
        }

        private struct Defaults {
            public static let url: String             = "http://127.0.0.1:5000";
            public static let contentType: String     = "application/json";
            public static let contentTypeName: String = "Content-Type";
            public static let pollingInterval: UInt64 = 300_000_000; // 300ms
        }

        private let url: URL;
        private var sentCount: Int = 0;

        public init(player: String? = nil, handler: XGameCenter.MessageHandler? = nil, url: URL? = nil) {
            self.player = player ?? ID(veryshort: true).value;
            self.handler = handler;
            self.url = url ?? URL(string: Defaults.url)!
        }
    }
}
