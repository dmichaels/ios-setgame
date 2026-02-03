import Foundation

public extension GameCenter
{
    public class HttpSession: Session {

        // MessageSender protocol implementation.

        public func send(message: Message) {
            return self.transportImp.send(message: message);
        }

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

        private var transportImp: GameCenter.HttpTransport;
        private var hostImp: String = "";
        private var playersImp: [String] = [];

        public init(transport: GameCenter.HttpTransport) {
            self.transportImp = transport;
        }

        public func start() async -> Bool {
            self.hostImp = await self.transportImp.retrieveHost();
            self.playersImp = await self.transportImp.retrievePlayers();
            return true;
        }

        public func bind(to handler: SessionMessageHandler) {
            self.transportImp.bind(to: handler);
            handler.session = self;
        }
    }
}
