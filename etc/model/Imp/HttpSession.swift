import Foundation

public extension GameCenter {

    public class HttpSession: Session {

        // Singleton instance.

        public private(set) static var instance: HttpSession? = nil;
        public static func instance(handler: SessionHandler, transport: HttpTransport.Factory? = nil) -> HttpSession {
            if let instance = HttpSession.instance {
                //
                // Should not normally happen; just call this once to initialize the singleton
                // with the required SessionHandler and (optional) HttpTransport arguments; but
                // if we do call it multiple times then we just replace the the singleton with
                // a new instance; we take care in this case to cleanup the existing singleton;
                // e.g. to stop HttpTransport polling via the Transport.release function.
                //
                print("NOT NORMAL> RECREATING HttpSession INSTANCE")
                instance.transport.release();
                HttpSession.instance = nil;
            }
            HttpSession.instance = HttpSession(handler: handler, transport: transport);
            return HttpSession.instance!;
        }

        // Session protocol implementation.

        public private(set) var session: String?;
        public var host: String { self.hostImp };
        public var transport: Transport { self.transportImp };

        public func create() async -> Bool {
            print("CREATING HOSTED SESSION> session: \(self.session) host: \(self.player)");
            if let session: String = await self.transportImp.createAndHostSession(host: self.player, bind: true) {
                self.session = session;
                self.hostImp = self.player;
                print("CREATED HOSTED SESSION> session: \(self.session) host: \(self.player)");
                self.transport.setup();
            }
            return false;
        }

        public func join(session: String?) async -> Bool {
            guard let session: String = session else { return false }
            return await self.join(session: session, direct: false);
        }

        private func join(session: String, direct: Bool = false) async -> Bool {
            guard !self.hosting else { print("BAD ATTEMPT OF HOST \(self.player) TO JOIN SESSION!!!") ; return false }
            if (direct) {
                print("JOINING SESSION DIRECTLY> player: \(self.player) host: \(self.host) session: \(session)")
                if let (player, host) = await self.transportImp.registerPlayer(self.player, session: session) {
                    print("JOINED SESSION DIRECTLY> player: \(player) host: \(host) session: \(session)")
                }
                else {
                    print("FAILED TO JOIN SESSION DIRECTLY> player: \(player) host: \(host) session: \(session)")
                    return false;
                }
            }
            else {
                print("JOINING SESSION INDIRECTLY> player: \(player) host: \(host) session: \(session) self.session: \(self.session)")
                if await self.transportImp.sendHostMessage(JoinSessionMessage(player: self.player), session: session) {
                    //
                    // Don't actually join the session yet, by setting our session ID;
                    // as we've only just sent a message to the host that we want to join;
                    // we need to wait until we receive a JoinedSessionMessage to do that;
                    // BUT we DO want to bind our transport polling so that it can even receive
                    // messages (most pointedly the aforementioned JoinedSessionMessage).
                    // self.session = session;
                    self.transportImp.bindSessionTentative(to: session);
                    print("JOINED SESSION INDIRECTLY> player: \(player) host: \(host) session: \(session) self.session: \(self.session)")
                }
                else {
                    print("FAILED TO JOIN SESSION INDIRECTLY> player: \(player) host: \(host) session: \(session) self.session: \(self.session)")
                    return false;
                }
            }
            self.transport.setup();
            return true;
        }

        // Sends the given message to the given player for the session.
        //
        public func send(message: Message, to player: String) async -> Bool {
            return await self.transportImp.sendMessage(message, player: player, session: self.session);
        }

        // Sends the given message to the HOST for the session via POST /<session>/send;
        // in contrast to sending a message to ANY player via POST /<session>/send/player.
        //
        public func sendHost(message: Message) async -> Bool {
            return await self.transportImp.sendHostMessage(message, session: self.session);
        }

        // Sends the given message to the given player for the session.
        // This is a NON-async version of the above for possible convenience;
        // since it is just a send and we do not really need to get/check the result.
        //
        public func send(message: Message, to player: String) -> Bool {
            return self.transportImp.sendMessage(message, player: player, session: self.session);
        }

        // Sends the given message to the HOST for the session via POST /<session>/send;
        // in contrast to sending a message to ANY player via POST /<session>/send/player.
        // This is a NON-async version of the above for possible convenience;
        // since it is just a send and we do not really need to get/check the result.
        //
        public func sendHost(message: Message) -> Bool {
            return self.transportImp.sendHostMessage(message, session: self.session);
        }

        // HttpSession class implementation.

        private let transportImp: HttpTransport;
        private var handler: SessionHandler;
        private var hostImp: String = "";

        public init(handler: SessionHandler, url: URL? = nil, transport: HttpTransport.Factory? = nil) {

            class MessageHandler: GameCenter.MessageHandler {
                var session: HttpSession?;
                func handle(message: PingMessage) { session?.handle(message: message) }
                func handle(message: JoinSessionMessage) { session?.handle(message: message) }
                func handle(message: JoinedSessionMessage) { session?.handle(message: message) }
            }

            self.session = "";

            // Bind ourselves to the given SessionHandler (which in our case is Table);
            // this is so we can pass on incoming messages to that SessionHandler.
            //
            self.handler = handler;

            // Bind the HttpTransport (ours or the given one via HttpTransport.Factory)
            // to a MessageHandler wrapper around our given SessionHandler; this is so
            // HttpTransport can pass incoming messages to us and we can then then pass
            // them on to the given SessionHandler, or in the case of session joining
            // related messages we handle those here (that specifically in fact is the
            // cause of this slightly confusing and complicated situation here).
            //
            let wrapper: MessageHandler = MessageHandler();
            self.transportImp = transport?(wrapper) ?? HttpTransport(handler: wrapper, url: url);
            wrapper.session = self;

            // Bind the given SessionHandler (which in our case is Table) to ourselves;
            // this is so this handler (Table in out case) can call into us (as an
            // implementor of Session) to send messages (via Session.send).
            //
            handler.session = self;
        }

        private func handle(message: PingMessage) {
            print("HANDLE PING MESSAGE> player: \(self.player) message: \(message) session: \(self.session)")
            self.handler.handle(message: message);
        }

        private func handle(message: JoinSessionMessage) {
            print("HANDLE JOIN MESSAGE> player: \(self.player) message: \(message) session: \(self.session) host: \(self.host) hosting: \(self.hosting)")
            Task {
                if let session: String = self.session {
                    let player: String = message.player
                    let message: GameCenter.Message = GameCenter.JoinedSessionMessage(session: session, host: self.player);
                    if let (player, host) = await self.transportImp.registerPlayerAndSend(player, message: message, session: session) {
                        print("HANDLE JOIN MESSAGE> REGISTERED-AND-SENT player: \(self.player) message: \(message) session: \(session)")
                    }
                }
            }
            self.handler.handle(message: message);
        }

        private func handle(message: JoinedSessionMessage) {
            print("HANDLE JOINED MESSAGE> player: \(self.player) session: \(self.session) host: \(self.host) hosting: \(self.hosting) message.session: \(message.session) message.host: \(message.host)")
            print("FOO: \(self.handler)")
            self.session = message.session;
            self.hostImp = message.host;
            print("HANDLE JOINED MESSAGE DONE> player: \(self.player) session: \(self.session) host: \(self.host) hosting: \(self.hosting) message.session: \(message.session) message.host: \(message.host)")
            // self.handler.handle(message: message);
        }
    }
}
