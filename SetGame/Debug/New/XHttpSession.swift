import Foundation

public extension XGameCenter
{
    public class HttpSession: Session {

        // Session protocol implementation.

        public var player: String {
            self.transportImp.player
        }

        public var host: String {
            // self.transportImp.retrieveHost()
            ""
        }

        public var hosting: Bool {
            // self.transportImp.retrieveHost() == self.player
            false
        }

        public var players: [String] {
            // self.transportImp.retrievePlayers()
            []
        }

        private var transportImp: XGameCenter.HttpTransport = XGameCenter.HttpTransport();

        public init(transport: XGameCenter.HttpTransport? = nil) {
            self.transportImp = transport ?? XGameCenter.HttpTransport();
        }
    }
}
