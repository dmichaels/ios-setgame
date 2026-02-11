class HttpSession: Session {

    // Singleton instance.

    private static var singleton: HttpSession? = nil;

    public static var instance: HttpSession? {
        return HttpSession.singleton;
    }

    public static func instance(handler: SessionHandler, transport: HttpTransport? = nil) -> HttpSession {
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
    public var transport: Transport { self.transportImp };
    public var host: String { self.hostImp }; // TODO

    public func create() async -> Bool {
        if let id: String = await self.transportImp.createSession(bind: true) {
            self.id = id;
            print("CREATED SESSION> \(self.id)");
            if let (player, host) = await self.transportImp.registerPlayer(self.player) {
                print("REGISTERED PLAYER> player: \(self.player) host: \(host) session: \(self.id)");
                self.hostImp = host;
                self.transport.setup();
            }
        }
        return false;
    }

    public func join(session id: String) async -> Bool {
        if let (player, host) = await self.transportImp.registerPlayer(player, session: id) {
            print("JOINED SESSION> player: \(player) host: \(host) session: \(id)")
            return true;
        }
        return false;
    }

    public func requestJoin(session id: String) {
        self.transportImp.sendMessage(JoinSessionMessage(player: self.player), session: id);
    }

    public func send(message: Message) {
        self.transportImp.sendMessage(message, session: self.id);
    }

    public func send(message: Message, to player: String) {
    }

    // HttpSession class implementation.

    private var transportImp: HttpTransport;
    private var handler: SessionHandler;
    private var hostImp: String = "";

    private init(handler: SessionHandler, transport: HttpTransport? = nil) {
        self.id = "";
        self.handler = handler;
        self.transportImp = transport ?? HttpTransport(handler: handler);
        //
        // Bind the handler (SessionHandler, e.g. Table) to self (Session);
        // this is so it (the Table implementing SessionHandler in our case)
        // can call into us (Session) to send messages (via Session.send).
        //
        // Question: Do we need to hold on to the instance of this SessionHandler?
        // We know that Transport needs it (asa MessageHandler which SessionHandler
        // implements) to call the MessageHandler.handle function(s) that Table in
        // our implements, for the messages that the transport receives; but not
        // sure we (the Session) needs to really do anything with this SessionHandler.
        //
        self.bind(to: handler);
        print("SESSION.INIT>                   \(ID.of(self))")
    }

    private func bind(to handler: SessionHandler) {
        handler.session = self;
    }

    public func report() {
        print("self: \(ID.of(self).hashValue) transport: \(ID.of(self.transport).hashValue)")
    }
}
