public extension MultiPlayer {

    public protocol Session: AnyObject {

        var  session: String? { get}
        var  player: String { get }
        var  host: String? { get }
        var  hosting: Bool { get }
        var  players: [String] { get }
        var  connected: Bool { get }
        var  leaveable: Bool { get }
        var  transport: Transport { get }

        func create() async -> Bool;
        func join(session: String?) async -> Bool;
        func join(session: String?, wait: Bool) async -> Bool;
        func leave() async -> Bool;
        func requestHost() async -> Bool;

        func send(message: Message, to: String) async -> Bool;
        func sendHost(message: Message) async -> Bool;

        func send(message: Message, to: String) -> Bool;
        func sendHost(message: Message) -> Bool;
    }
}

public extension MultiPlayer.Session {
    public var player: String { self.transport.player };
    public var hosting: Bool { self.player == self.host };
    public var connected: Bool { self.session != nil };
    public var leaveable: Bool { self.session != nil && (!self.hosting || self.players.count == 1) };
}
