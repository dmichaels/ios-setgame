import Foundation

public extension GameCenter
{
    public class HttpSession: Session {

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
            self.transportImp.start();
            self.hostImp = await self.transportImp.retrieveHost();
            self.playersImp = await self.transportImp.retrievePlayers();
            return true;
        }

        public func start() {
            // self.rng.reset();
            self.handler?.play();
        }

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
