import Foundation

public extension GameCenter
{
    public class HttpSession: Session {

        // Session protocol implementation.

        public var player: String {
            return self.transportImp.player;
        }

        public var host: String {
            return self.hostImp;
        }

        public var hosting: Bool {
            return self.player == self.host;
        }

        public var players: [String] {
            return self.playersImp;
        }

        // HttpSession implementation.

        private var transportImp: GameCenter.HttpTransport = GameCenter.HttpTransport();
        private var hostImp: String = "";
        private var playersImp: [String] = [];

        public init(transport: GameCenter.HttpTransport? = nil) {
            self.transportImp = transport ?? GameCenter.HttpTransport();
        }

        public func start(bind: MessageHandler) async -> Bool {
            self.hostImp = await self.transportImp.retrieveHost();
            self.playersImp = await self.transportImp.retrievePlayers();
            self.transportImp.bind(to: bind);
            return true;
        }
    }
}
