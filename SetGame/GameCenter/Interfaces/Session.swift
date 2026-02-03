import Foundation

public extension GameCenter
{
    public protocol Session: MessageSender {
        var  transport: Transport { get }
        var  player: String { get };
        var  host: String { get };
        var  hosting: Bool { get };
        var  players: [String] { get };
        func start() async -> Bool;
        func bind(to: SessionMessageHandler);

        func register() async; // TODO to register host via dev panel
        func reset(); // TODO to reset host via dev panel
    }
}

extension GameCenter.Session {
    public var hosting: Bool {
        return self.player == self.host;
    }
    public func bind(to handler: GameCenter.SessionMessageHandler) {
        self.transport.bind(to: handler);
        handler.session = self;
    }
}
