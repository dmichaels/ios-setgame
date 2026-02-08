import Foundation

public extension GameCenter
{
    public protocol Session: AnyObject {
        var  transport: Transport { get }
        var  handler: SessionHandler? { get set }
        var  player: String { get };
        var  host: String { get };
        var  hosting: Bool { get };
        var  players: Set<String> { get };
        func setup() async -> Bool;
        func release();
        func bind(to: SessionHandler);
        func start();
        func send(message: Message);
        func send(message: Message, to player: String);
        func handle(message: GameCenter.PlayerReadyMessage);
        var  rng: RNG { get }
    }
}

extension GameCenter.Session {

    public var player: String {
        return self.transport.player;
    }

    public var hosting: Bool {
        return self.player == self.host;
    }

    public func bind(to handler: GameCenter.SessionHandler) {
        self.transport.bind(to: handler);
        handler.session = self;
        self.handler = handler;
    }

    public func send(message: GameCenter.Message) {
        if (self.hosting) {
            //
            // We are the HOST; send the message to ALL of the clients;
            // and INCLUDING to ourselves (the host), so that we (the
            // host) act as much as possible like the clients.
            //
            for player in self.players {
                self.transport.send(message: message, to: player);
            }
        }
        else {
            //
            // We are the CLIENT (NOT the HOST);
            // send the message ONLY to the HOST.
            //
            self.transport.send(message: message, to: self.host);
        }
    }

    public func send(message: GameCenter.Message, to player: String) {
        self.transport.send(message: message, to: player);
    }
}
