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

        // public var hosting: Bool {
            // return self.player == self.host;
        // }

        public var players: [String] {
            return self.playersImp;
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
            self.hostImp = await self.transportImp.retrieveHost();
            self.playersImp = await self.transportImp.retrievePlayers();
            return true;
        }
    }
}
