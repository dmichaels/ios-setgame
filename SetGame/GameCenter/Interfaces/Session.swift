import Foundation

public extension GameCenter
{
    public protocol Session: AnyObject {
        var  transport: Transport { get }
        var  handler: SessionHandler? { get set }
        var  player: String { get };
        var  host: String { get };
        var  hosting: Bool { get };
        var  players: [String] { get };
        func setup(instance: Bool) async -> Bool;
        func bind(to: SessionHandler);
        func start();
        func send(message: Message);
        func send(message: Message, to player: String);
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
}
