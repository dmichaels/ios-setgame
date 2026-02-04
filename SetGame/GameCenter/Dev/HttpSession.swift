import Foundation

public extension GameCenter
{
    public class HttpSession: Session {

        // MessageSender (via Sender) protocol implementation.

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

        // Session protocol implementation.

        public let transport: Transport;

        // public var player: String { return self.transportImp.player; }

        public var host: String {
            return self.hostImp;
        }

        public var players: [String] {
            return self.playersImp;
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

        // HttpSession implementation.

        private let transportImp: GameCenter.HttpTransport;
        private var hostImp: String = "";
        private var playersImp: [String] = [];

        public init(transport: GameCenter.HttpTransport) {
            self.transport = transport;
            self.transportImp = transport;
        }

        public func start() async -> Bool {
            self.transportImp.start();
            self.hostImp = await self.transportImp.retrieveHost();
            self.playersImp = await self.transportImp.retrievePlayers();
            return true;
        }
    }
}
