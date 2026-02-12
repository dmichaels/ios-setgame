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
                instance.transport.release();
                HttpSession.instance = nil;
            }
            HttpSession.instance = HttpSession(handler: handler, transport: transport);
            return HttpSession.instance!;
        }

        // Session protocol implementation.

        public private(set) var session: String?;
        public var host: String { self.hostImp ?? "" };
        public var transport: Transport { self.transportImp };

        public func create() async -> Bool {
            if let session: String = await self.transportImp.createAndHostSession(host: self.player, bind: true) {
                self.session = session;
                self.hostImp = self.player;
                self.transport.setup();
                return true;
            }
            return false;
        }

        public func join(session: String?, wait: Bool?) async -> Bool {
            guard let session: String = session, !self.hosting else { return false }
            guard !self.hosting else { return false }
            if let wait: Bool = wait {
                if (wait) {
                    //
                    // If the wait argument is true then send a
                    // join message to the host and wait for its return.
                    //
                    return await self.joinAsyncWithWait(session: session);
                }
                else {
                    //
                    // If the wait argument is false then send a join message to
                    // the host and do not wait for its return; i.e. fire-and-forget.
                    //
                    return await self.joinAsync(session: session);
                }
            }
            else {
                //
                // If the wait argument is nil then join directly via the server API.
                //
                return await self.joinDirect(session: session);
            }
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
        private var hostImp: String?;
        private var joinSessionContinuation: CheckedContinuation<Void, Error>?

        public init(handler: SessionHandler, url: URL? = nil, transport: HttpTransport.Factory? = nil) {

            class MessageHandler: GameCenter.MessageHandler {
                var session: HttpSession?;
                func handle(message: PingMessage) { session?.handle(message: message) }
                func handle(message: JoinSessionMessage) { session?.handle(message: message) }
                func handle(message: JoinedSessionMessage) { session?.handle(message: message) }
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
            self.transportImp = transport?(wrapper) ?? HttpTransport(handler: wrapper, url: url);
            wrapper.session = self;

            // Bind the given SessionHandler (which in our case is Table) to ourselves;
            // this is so this handler (Table in out case) can call into us (as an
            // implementor of Session) to send messages (via Session.send).
            //
            handler.session = self;
        }

        private func joinDirect(session: String?) async -> Bool {
            guard self.session == nil else { return false }
            guard let session: String = session, !self.hosting else { return false }
            if let (player, host) = await self.transportImp.registerPlayer(self.player, session: session) {
                self.session = session;
                self.hostImp = host;
                self.transportImp.bindSession(to: session);
                self.transport.setup();
                return true;
            }
            return false;
        }

        private func joinAsyncWithWait(session: String?) async -> Bool {
            guard let session: String = session, !self.hosting else { return false }
            do {
                let success: Bool = try await withTimeout(seconds: 5) {
                    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                        self.joinSessionContinuation = continuation
                        Task {
                            let message = JoinSessionMessage(player: self.player)
                            if await self.transportImp.sendHostMessage(message, session: session) {
                                self.transportImp.bindSessionTentative(to: session);
                                self.transport.setup();
                            }
                        }
                    }
                    return true;
                }
                return success;
            }
            catch {
                return false;
            }
        }

        private func joinAsync(session: String) async -> Bool {
            if await self.transportImp.sendHostMessage(JoinSessionMessage(player: self.player), session: session) {
                //
                // Don't actually join the session yet, by setting our session ID;
                // as we've only just sent a message to the host that we want to join;
                // we need to wait until we receive a JoinedSessionMessage to do that;
                // BUT we DO want to bind our transport polling so that it can even receive
                // messages (most pointedly the aforementioned JoinedSessionMessage).
                // self.session = session;
                //
                self.transportImp.bindSessionTentative(to: session);
                self.transport.setup()
                return true;
            }
            else {
                return false;
            }
        }

        private func handle(message: PingMessage) {
            self.handler.handle(message: message);
        }

        private func handle(message: JoinSessionMessage) {
            Task {
                if let session: String = self.session {
                    let player: String = message.player
                    let message: GameCenter.Message = GameCenter.JoinedSessionMessage(session: session, host: self.player);
                    if let (player, host) = await self.transportImp.registerPlayerAndSend(player, message: message, session: session) {
                    }
                }
            }
        }

        private func handle(message: JoinedSessionMessage) {
            print("HANDLE(JOINED): \(self.joinSessionContinuation)")
            if let continuation = self.joinSessionContinuation {
                print("HANDLE(JOINED): \(self.joinSessionContinuation) -> CONTINUATION")
                self.session = message.session;
                self.hostImp = message.host;
                self.transportImp.bindSession(to: message.session);
                self.joinSessionContinuation = nil;
                continuation.resume(returning: ());
            }
            else {
                self.session = message.session;
                self.hostImp = message.host;
                self.transportImp.bindSession(to: message.session);
            }
        }
    }
}

func withTimeout<T>(
    seconds: TimeInterval,
    operation: @escaping () async throws -> T
) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask {
            try await operation()
        }
        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            throw TimeoutError()
        }

        let result = try await group.next()!
        group.cancelAll()
        return result
    }
}

struct TimeoutError: Error {}
