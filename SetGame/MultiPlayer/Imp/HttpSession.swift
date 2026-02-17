import Foundation

public extension MultiPlayer {

    public class HttpSession: Session {

        // Singleton instance.

        public private(set) static var singleton: HttpSession? = nil;
        public static var instance: HttpSession { HttpSession.singleton! }
        public static func instance(handler: SessionHandler, transport: HttpTransport.Factory? = nil) -> HttpSession {
            if let singleton = HttpSession.singleton {
                //
                // Should not normally happen; just call this once to initialize the singleton
                // with the required SessionHandler and (optional) HttpTransport arguments; but
                // if we do call it multiple times then we just replace the the singleton with
                // a new instance; we take care in this case to cleanup the existing singleton;
                // e.g. to stop HttpTransport polling via the Transport.disengage function.
                //
                singleton.transport.disengage();
                HttpSession.singleton = nil;
            }
            HttpSession.singleton = HttpSession(handler: handler, transport: transport);
            return HttpSession.singleton!;
        }

        // Session protocol implementation.

        public private(set) var session: String?;
        public private(set) var host: String?
        public private(set) var players: [String] = [];
        public private(set) var transport: Transport;

        public func create() async -> Bool {
            //
            // If a session has already been created (or joined),
            // i.e. self.session is not nil, then do nothing; return false.
            //
            if (self.session == nil) {
                if let session: String = await self.transport.create(host: self.player, bind: true) {
                    self.connect(session: session, host: self.player, players: [self.player]);
                    self.transport.engage();
                    return true;
                }
            }
            return false;
        }

        public func join(session: String?) async -> Bool {
            return await self.join(session: session, wait: true);
        }

        // Joins to this (assumed) non-host player to the given session ID,
        // by sending a JoinSessionMessage to the host; the host will presumably
        // honor this request, add the player to the session (via backend server API),
        // and then will send a JoinSessionConfirmedMessage back to this player for confirmation.
        //
        public func join(session: String?, wait: Bool) async -> Bool {
            guard let session: String = session, !self.hosting else { return false }
            if (wait) {
                //
                // If the wait argument is true then send a
                // join message to the host and wait for its return.
                //
                return await self.joinAsyncAndWait(session: session);
            }
            else {
                //
                // If the wait argument is false then send a join message to
                // the host and do not wait for its return; i.e. fire-and-forget.
                //
                return await self.joinAsync(session: session);
            }
        }

        public func requestHost() async -> Bool {
            guard let session: String = self.session, !self.hosting else { return false }
            return await self.sendHost(message: RequestHostSessionMessage(player: self.player));
        }

        public func leave() async -> Bool {
            guard let session: String = self.session else { return false }
            if (self.hosting) {
                if (self.players.count == 1) {
                    if await self.transport.destroySession(session: session) {
                        self.disconnect();
                        return true;
                    }
                }
                return false;
            }
            else {
                await self.sendHost(message: LeaveSessionMessage(player: self.player));
                self.disconnect();
                return true;
            }
        }

        // Sends the given message to the given player for the session.
        //
        public func send(message: Message, to player: String) async -> Bool {
            return await self.transport.send(message: message, player: player, session: self.session);
        }

        // Sends the given message to the HOST for the session via POST /<session>/send;
        // in contrast to sending a message to ANY player via POST /<session>/send/player.
        //
        public func sendHost(message: Message) async -> Bool {
            return await self.transport.sendHost(message: message, session: self.session);
        }

        public func disconnect() {
            self.session = nil;
            self.host = nil;
            self.players = [];
            self.transport.disengage();
        }

        public func connect(session: String, host: String, players: [String]) {
            self.session = session;
            self.host = host;
            self.players = players;
        }

        // HttpSession class implementation.

        private var handler: SessionHandler;
        private var joinSessionContinuation: CheckedContinuation<Void, Error>?

        public init(handler: SessionHandler, url: String? = nil, transport: HttpTransport.Factory? = nil) {

            class MessageHandler: MultiPlayer.MessageHandler {
                var session: HttpSession?;
                func handle(message: PingMessage) { session?.handle(message: message) }
                func handle(message: JoinSessionMessage) { session?.handle(message: message) }
                func handle(message: JoinSessionConfirmedMessage) { session?.handle(message: message) }
                func handle(message: LeaveSessionMessage) { session?.handle(message: message) }
                func handle(message: RequestHostSessionMessage) { session?.handle(message: message) }
                func handle(message: UpdateSessionMessage) { session?.handle(message: message) }
                func handle(message: NewGameMessage) { session?.handle(message: message) }
                func handle(message: SetFoundMessage) { session?.handle(message: message) }
                func handle(message: SetConfirmedMessage) { session?.handle(message: message) }
                func handle(message: SetMissedMessage) { session?.handle(message: message) }
            }

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
            self.transport = transport?(wrapper) ?? HttpTransport(handler: wrapper, url: url);
            wrapper.session = self;

            // Bind the given SessionHandler (which in our case is Table) to ourselves;
            // this is so this handler (Table in out case) can call into us (as an
            // implementor of Session) to send messages (via Session.send).
            //
            handler.xsession = self;

            // N.B. Do not initialize the players list with ourselves,
            // because we are not actually connected session on construction;
            // we only become a connected session via create or join session,
            // at which time we will add ourselves as a (the first) player.
            // self.playerJoined(self.player);
        }

        private func joinAsync(session: String) async -> Bool {
            let message: Message = JoinSessionMessage(player: self.player);
            if await self.transport.sendHost(message: message, session: session) {
                //
                // Don't actually join the session yet, by setting our session ID;
                // as we've only just sent a message to the host that we want to join;
                // we need to wait until we receive a JoinSessionConfirmedMessage to do that;
                // BUT we DO want to bind our transport polling so that it can even receive
                // messages (most pointedly the aforementioned JoinSessionConfirmedMessage).
                //
                self.transport.bindTentative(to: session);
                self.transport.engage();
                return true;
            }
            else {
                return false;
            }
        }

        private func joinAsyncAndWait(session: String?) async -> Bool {
            guard let session: String = session, !self.hosting else { return false }
            do {
                let success: Bool = try await withTimeout(seconds: 5) { // TODO this timeout might not be working
                    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                        self.joinSessionContinuation = continuation
                        Task { await self.joinAsync(session: session) }
                    }
                    return true;
                }
                return success;
            }
            catch {
                return false;
            }
        }

        private func handle(message: PingMessage) {
            self.handler.handle(message: message);
        }

        private func handle(message: JoinSessionMessage) {
            guard self.hosting else { return }
            //
            // We are presumed here to be the HOST player.
            // This is a request message from a non-host player to join this session.
            //
            Task {
                if let session: String = self.session {
                    //
                    // Currently just blindly accept this join request; register the player,
                    // identified in the message, for our session (via backend server API); and
                    // send a notification message to this player that their request has been accepted.
                    // 
                    if let (player, host) = await self.transport.register(player: message.player, session: session) {
                        //
                        // Add this player to our list of known players (which includes ourself FYI).
                        // And then notify the other player excluding this (host) player, so that the
                        // other (non-host) players can update their players list. Note: Initially
                        // thought we could exclude the player just added here from the update, but
                        // think wires could get crossed (TODO: think through some more); it should
                        // not hurt at any rate just to send out UpdateSessionMessage as this just
                        // synchronizes the host and players with the (non-host) clients to the host values.
                        //
                        self.playerJoined(message.player);
                        self.host = host;
                    }
                }
            }
        }

        private func handle(message: JoinSessionConfirmedMessage) {
            guard !self.hosting else { return }
            //
            // We are presumed here to be a NON-host player.
            // This is a notification message from the host player
            // that our request to join their session as been accepted.
            // Note that we add the host (from the message) to our players list.
            //
            if let continuation = self.joinSessionContinuation {
                self.joinSessionContinuation = nil;
                continuation.resume(returning: ());
            }
            self.connect(session: message.session, host: message.host, players: self.players + [self.player]);
            self.transport.bind(to: message.session);
        }

        private func handle(message: LeaveSessionMessage) {
            guard self.hosting else { return }
            Task {
                if await self.transport.unregister(player: message.player, session: session) {
                    self.playerLeft(message.player);
                }
            }
        }

        private func handle(message: RequestHostSessionMessage) {
            guard self.hosting else { return }
            Task {
                if await self.transport.requestHost(player: message.player, session: session) {
                    self.host = message.player;
                }
            }
        }

        private func handle(message: UpdateSessionMessage) {
            self.host = message.host;
            self.players = message.players;
        }

        private func handle(message: NewGameMessage) {
            deb("TODO: HANDLE NewGameMessage!")
        }

        private func handle(message: SetFoundMessage) {
            deb("TODO: HANDLE SetFoundMessage!")
        }

        private func handle(message: SetConfirmedMessage) {
            deb("TODO: HANDLE SetConfirmedMessage!")
        }

        private func handle(message: SetMissedMessage) {
            deb("TODO: HANDLE SetMissedMessage!")
        }

        private func playerJoined(_ player: String) {
            if (!self.players.contains(player)) {
                self.players.append(player);
            }
        }

        private func playerLeft(_ player: String) {
            if let index = self.players.firstIndex(of: player) {
                self.players.remove(at: index);
            }
        }
    }
}
