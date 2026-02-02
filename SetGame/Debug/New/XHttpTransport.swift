import Foundation

public extension XGameCenter
{
    public class HttpTransport: XGameCenter.Transport {

        // Transport protocol implementation.

        public var player: String = ID(veryshort: true).value;

        public func start() {
            //
            // TODO
            //
        }

        public func stop() {
            //
            // TODO
            //
        }

        public func bind(to handler: XGameCenter.MessageHandler) {  // Transport imp
            self.handler = handler;
            handler.sender = self;
        }

        // MessageSender protocol implementation.

        public func send(message: Message) {
            //
            // TODO
            //
        }

        // MessageHandler protocol implementation.

        public var sender: MessageSender? {
            get { self }
            set { }
        }

        public func handle(message: PingMessage) {
            //
            // TODO
            //
        }

        public func handle(message: PlayerReadyMessage) {
            //
            // TODO
            //
        }

        public func handle(message: NewGameMessage) {
            //
            // TODO
            //
        }

        public func handle(message: FoundSetMessage) {
            //
            // TODO
            //
        }

        public func handle(message: ConfirmedSetMessage) {
            //
            // TODO
            //
        }

        // HttpTransport class implementation.

        private var handler: XGameCenter.MessageHandler? = nil;

        private struct Defaults {
            public static let url: String             = "http://127.0.0.1:5000";
            public static let contentType: String     = "application/json";
            public static let contentTypeName: String = "Content-Type";
            public static let pollingInterval: UInt64 = 300_000_000; // 300ms
        }

        private struct Counts {
            public var sent: Int = 0;
            public var retrieved: Int = 0;
            public var handled: Int = 0;
        }

        private let url: URL;
        private let counts: Counts = Counts();

        public init(player: String? = nil,  url: URL? = nil) {
            self.player = player ?? ID(veryshort: true).value;
            self.url = url ?? URL(string: Defaults.url)!
        }
    }
}
