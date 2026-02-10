import Foundation

public extension GameCenter
{
    public class HttpSession: Session {

        public static private(set) var singleton: HttpSession? = nil;

        // This is really just for the debug/dev control panel.
        //
        public static private(set) var instance: HttpSession? = nil;

        // Session protocol implementation.

        public private(set) var id: String?;
        public let transport: Transport;
        public private(set) var handler: SessionHandler? = nil;
        // public var handler: SessionHandler? = nil;
    public func bind(to handler: GameCenter.SessionHandler) {
        self.transport.bind(to: handler);
        handler.session = self;
        self.handler = handler;
    }

        public var host: String {
            return self.hostImp;
        }

        public var players: [String] {
            return self.playersImp;
        }

        public func setup() {

            Task {

                // Create a session with the server.

                if let session: String = await self.transportImp.createSession() {
                    self.id = session;
                    // todo/xyzzy/testing
                    let xa = await self.transportImp.register();
                    let xb = await self.transportImp.sendMessage(GameCenter.PingMessage(), to: self.player);
                    let x = 1
                    let y = await self.transportImp.destroySession()
                    let z = 1
                }

                // Register this player with the server.
                // This also discovers the host player (if already set)
                // or sets this player as the host player (if not already set).

                await self.register();

                if (self.hosting) {
                    //
                    // Note that this authoritative list of players is known and maintained
                    // ONLY by the HOST; we notify the (non-host) clients of players only in the
                    // context of letting them know what the current score is among all of the players;
                    // but other than that the (non-host) clients don't "know" about the other players.
                    //
                    self.playersImp = await self.transportImp.retrievePlayers();
                }
                else {
                    //
                    // For the non-host clients we send the host a PlayerReady message;
                    // the host will use this to add to its set of known players; the
                    // in host could also just use that message as a signal to update
                    // its player list from the server since it has a definitie list;
                    // just as a sort of extra sanity check.
                    //
                    await self.send(message: GameCenter.PlayerReadyMessage(player: self.player));
                }

                // Setup the Transport; starts the polling if not yet started.

                self.transport.setup();
            }
        }
/*
        public func setup() await -> Bool {

            // Maintain our singleton HttpSession instance;
            // this is really just for our debug/dev control panel.

            if let instance: HttpSession = HttpSession.instance {
                if (instance !== self) {
                    instance.transport.release();
                    HttpSession.instance = nil;
                }
            }

            // Setup the Transport; starts the polling if not yet started.

            self.transport.setup();

            // Create a session with the server.

            if let session: String = await self.transportImp.createSession() {
                self.id = session;
            }

            // Register this player with the server.
            // This also discovers the host player (if already set)
            // or sets this player as the host player (if not already set).

            await self.register();

            if (self.hosting) {
                //
                // Note that this authoritative list of players is known and maintained
                // ONLY by the HOST; we notify the (non-host) clients of players only in the
                // context of letting them know what the current score is among all of the players;
                // but other than that the (non-host) clients don't "know" about the other players.
                //
                self.playersImp = await self.transportImp.retrievePlayers();
            }
            else {
                //
                // For the non-host clients we send the host a PlayerReady message;
                // the host will use this to add to its set of known players; the
                // in host could also just use that message as a signal to update
                // its player list from the server since it has a definitie list;
                // just as a sort of extra sanity check.
                //
                await self.send(message: GameCenter.PlayerReadyMessage(player: self.player));
            }

            return true;
        }
*/

        public func handle(message: GameCenter.PlayerReadyMessage) {
            deb("HttpSession.handle(PlayerReadyMessage): \(message.player)")
            Task {
                await self.register(player: message.player);
                if (self.hosting) {
                    deb("HttpSession.handle(PlayerReadyMessage): \(message.player) - hosting and updating players")
                    self.playersImp = await self.transportImp.retrievePlayers();
                    deb("HttpSession.handle(PlayerReadyMessage): \(message.player) - hosting and updated players: \(self.playersImp)")
                }
            }
        }

        public func start() {
            deb("HttpSession.start")
            self.handler?.play();
        }

        public final lazy var rng: RNG = { return RNG() }()

        // HttpSession implementation.

        private let transportImp: GameCenter.HttpTransport;
        private var hostImp: String = "";
        private var playersImp: [String] = [];

        public static func create(handler: SessionHandler, transport: GameCenter.HttpTransport? = nil) {
            if let instance: HttpSession = HttpSession.instance {
                instance.transport.release();
                HttpSession.instance = nil;
            }
            HttpSession.instance = HttpSession(handler: handler, transport: transport);
            //
            // xyzzy
            HttpSession.instance?.setup();
        }

        private init(handler: SessionHandler, transport: GameCenter.HttpTransport? = nil) {
            self.transportImp = transport ?? GameCenter.HttpTransport();
            self.transport = self.transportImp;
            self.bind(to: handler);
        }

/*
        public static func create(handler: SessionHandler) async -> Session? {
            let session: Session = HttpSession(transport: HttpTransport());
            if (await session.setup()) {
                session.bind(to: handler);
                return session;
            }
            else {
                session.release();
                return nil;
            }
        }

        public init(transport: GameCenter.HttpTransport? = nil, seed: Int? = nil) {
            let transport: HttpTransport = transport ?? GameCenter.HttpTransport();
            self.transport = transport;
            self.transportImp = transport;
        }
*/

        public func register(player: String? = nil) async {
            if let (_, host) = await self.transportImp.register(player: player ?? self.player) {
                self.hostImp = host;
            }
        }

        public func updatePlayerInfo() {
            Task {
                self.hostImp = await self.transportImp.retrieveHost();
                self.playersImp = await self.transportImp.retrievePlayers();
            }
        }
    }
}
