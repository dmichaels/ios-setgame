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
            self.rng?.reset();
            self.handler?.play();
        }

        public func send(message: Message) {
            if (self.hosting) {
                //
                // If we are the HOST, then send the message to ALL clients;
                // and INCLUDING to ourselves (the host), so that we (the
                // host) act as much as possible like the clients.
                //
                for player in self.players {
                    self.transportImp.send(message: message, to: player);
                }
            }
            else {
                //
                // If we are the CLIENT (i.e. NOT the HOST),
                // then send the message ONLY to the HOST.
                //
                self.transportImp.send(message: message, to: self.host);
            }
        }

        public func send(message: Message, to player: String) {
            self.transportImp.send(message: message, to: player);
        }

        public var rng: RNG? {
            return self.rngImp;
        }

        // HttpSession implementation.

        private let transportImp: GameCenter.HttpTransport;
        private var hostImp: String = "";
        private var playersImp: [String] = [];
        private let rngImp: RNG;

        public init(transport: GameCenter.HttpTransport, seed: Int? = nil) {
            self.transport = transport;
            self.transportImp = transport;
            self.rngImp = RNG(seed: seed ?? Defaults.multiPlayer.rngseed);
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
