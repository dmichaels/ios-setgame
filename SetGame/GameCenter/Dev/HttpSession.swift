import Foundation

public extension GameCenter
{
    public class HttpSession: Session {

        // MessageSender (via Sender) protocol implementation.

        public func send(message: Message) {
            return self.transportImp.send(message: message);
        }

        // Session protocol implementation.

        public let transport: Transport;

        public var player: String {
            return self.transportImp.player;
        }

        public var host: String {
            return self.hostImp;
        }

        public var players: [String] {
            return self.playersImp;
        }

        public func register() async {
            await self.transportImp.register();
            await self.reset();
        }

        public func reset() {
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
