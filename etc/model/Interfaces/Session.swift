public extension GameCenter {

    public protocol Session: AnyObject {
        var  session: String? { get}
        var  player: String { get }
        var  host: String { get }
        var  hosting: Bool { get }
        var  transport: Transport { get }
        func create() async -> Bool;
        func join(session: String?) async -> Bool;
        func joinSession(sessionID: String) async -> Bool;
        func send(message: Message, to: String) async -> Bool;
        func sendHost(message: Message) async -> Bool;
        func send(message: Message, to: String) -> Bool;
        func sendHost(message: Message) -> Bool;
    }
}

public extension GameCenter.Session {
    public var player: String { self.transport.player };
    public var hosting: Bool { self.player == self.host };
}
