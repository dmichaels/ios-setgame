import Foundation

public extension GameCenter
{
    public class HttpSession: Session {

        // This is really just for the debug/dev panel.
        //
        public static private(set) var instance: HttpSession? = nil;

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

        // Session protocol implementation.

        public let transport: Transport;
        public var handler: SessionHandler? = nil;

        public var host: String {
            return self.hostImp;
        }

        public var players: [String] {
            return self.playersImp;
        }

        public func setup() async -> Bool {
            if let instance: HttpSession = HttpSession.instance {
                if (instance !== self) {
                    instance.transport.release();
                    HttpSession.instance = nil;
                }
            }
            self.transportImp.setup();
            self.hostImp = await self.transportImp.retrieveHost();
            self.playersImp = await self.transportImp.retrievePlayers();
            if (self.hostImp.isEmpty) {
                await self.transportImp.register(player: self.player);
                self.hostImp = await self.transportImp.retrieveHost();
                self.playersImp = await self.transportImp.retrievePlayers();
            }
            else if (!self.hosting) {
                await self.send(message: GameCenter.PlayerReadyMessage(player: self.player));
            }
            HttpSession.instance = self;
            return true;
        }

        public func handle(message: GameCenter.PlayerReadyMessage) {
            deb("HttpSession.handle(PlayerReadyMessage): \(message.player)")
            Task {
                await self.transportImp.register(player: message.player);
                self.playersImp = await self.transportImp.retrievePlayers();
                self.hostImp = await self.transportImp.retrieveHost();
            }
        }

        public func release() {
            if let instance: HttpSession = HttpSession.instance {
                instance.transport.release();
                HttpSession.instance = nil;
            }
        }

        public func start() {
            deb("HttpSession.start")
            self.handler?.play();
        }

/*
        public func send(message: Message) {
            if (self.hosting) {
                //
                // We are the HOST; send the message to ALL of the clients;
                // and INCLUDING to ourselves (the host), so that we (the
                // host) act as much as possible like the clients.
                //
                for player in self.players {
                    self.transportImp.send(message: message, to: player);
                }
            }
            else {
                //
                // We are the CLIENT (NOT the HOST);
                // send the message ONLY to the HOST.
                //
                self.transportImp.send(message: message, to: self.host);
            }
        }

        public func send(message: Message, to player: String) {
            self.transportImp.send(message: message, to: player);
        }
*/

        public final lazy var rng: RNG = { return RNG() }()

        // HttpSession implementation.

        private let transportImp: GameCenter.HttpTransport;
        private var hostImp: String = "";
        private var playersImp: [String] = [];

        public init(transport: GameCenter.HttpTransport? = nil, seed: Int? = nil) {
            let transport: HttpTransport = transport ?? GameCenter.HttpTransport();
            self.transport = transport;
            self.transportImp = transport;
        }

        public func register() async {
            await self.transportImp.register();
            await self.updatePlayers();
        }

        public func updatePlayers() {
            Task {
                self.hostImp = await self.transportImp.retrieveHost();
                self.playersImp = await self.transportImp.retrievePlayers();
            }
        }
    }
}
