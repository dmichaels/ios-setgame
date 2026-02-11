public extension GameCenter {

    public class HttpSession: Session {

        // Singleton instance.

        private static var singleton: HttpSession? = nil;

        public static var instance: HttpSession? {
            return HttpSession.singleton;
        }

        // public static func instance(handler: SessionHandler, transport: HttpTransport? = nil) -> HttpSession {
        public static func instance(handler: SessionHandler, transport: HttpTransportFactory? = nil) -> HttpSession {
            if let instance = HttpSession.singleton {
                //
                // Should not normally happen; just call this once to initialize the singleton
                // with the required SessionHandler and (optional) HttpTransport arguments; but
                // if we do call it multiple times then we just replace the the singleton with
                // a new instance; we take care in this case to cleanup the existing singleton;
                // e.g. to stop HttpTransport polling via the Transport.release function.
                //
                instance.transport.release();
                HttpSession.singleton = nil;
            }
            HttpSession.singleton = HttpSession(handler: handler, transport: transport);
            return HttpSession.singleton!;
        }

        // Session protocol implementation.

        public private(set) var id: String;
        public var host: String { self.hostImp };
        public var transport: Transport { self.transportImp };

        public func create() async -> Bool {
            print("CREATING HOSTED SESSION> session: \(self.id) host: \(self.player)");
            if let id: String = await self.transportImp.createAndHostSession(host: self.player, bind: true) {
                self.id = id;
                print("CREATED HOSTED SESSION> session: \(self.id) host: \(self.player)");
                self.hostImp = host;
                self.transport.setup();
            }
            return false;
        }

        public func join(session id: String) async -> Bool {
            if let (player, host) = await self.transportImp.registerPlayer(self.player, session: id) {
                print("JOINED SESSION> player: \(player) host: \(host) session: \(id)")
                return true;
            }
            return false;
        }

        public func send(message: Message) {
            //
            // Sends to the host of the session via POST /<session>/send,
            // in contrast to sending to any player via POST /<session>/send/player.
            //
            self.transportImp.sendMessage(message, session: self.id);
        }

        public func send(message: Message, to player: String) {
            self.transportImp.sendMessage(message, player: player, session: self.id);
        }

        // HttpSession class implementation.

        private let transportImp: HttpTransport;
        private var handler: SessionHandler;
        private var hostImp: String = "";


        private init(handler: SessionHandler, transport: HttpTransportFactory? = nil) {

            class MessageHandler: GameCenter.MessageHandler {
                var session: HttpSession?;
                func handle(message: PingMessage) { session?.handler.handle(message: message) }
                func handle(message: JoinSessionMessage) { session?.handle(message: message) }
                func handle(message: JoinedSessionMessage) { session?.handle(message: message) }
            }

            self.id = "";
            self.handler = handler;

            let handlerWrapper: MessageHandler = MessageHandler();
            self.transportImp = transport?(handlerWrapper) ?? HttpTransport(handler: handlerWrapper);
            handlerWrapper.session = self;

            // self.transportImp = HttpTransport(handler: handlerWrapper);

            // self.transportImp = transport ?? HttpTransport(handler: handler); // hmm
            // self.transportImp = transport ?? HttpTransport(handler: handler); // hmm
            // self.transportImp = transport ?? HttpTransport(handler: self); // hmm

            // Bind the handler (SessionHandler, e.g. Table) to self (Session);
            // this is so it (the Table implementing SessionHandler in our case)
            // can call into us (Session) to send messages (via Session.send).
            handler.session = self;
        }

        public func requestJoin(session id: String) {
            if (self.transportImp.sendMessage(JoinSessionMessage(player: self.player), session: id)) {
                self.transport.setup();
            }
        }

        private func handle(message: PingMessage) {
            self.handler.handle(message: message);
        }

        private func handle(message: JoinSessionMessage) {
            self.handler.handle(message: message);
        }

        private func handle(message: JoinedSessionMessage) {
            self.handler.handle(message: message);
        }

        public func report() {
            print("self: \(ID.of(self).hashValue) transport: \(ID.of(self.transport).hashValue)")
        }
    }
}
