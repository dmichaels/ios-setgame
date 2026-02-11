public protocol Session: AnyObject {
    var  id: String { get}
    var  player: String { get }
    var  transport: Transport { get }
    func send(message: Message, to: String);
    func create() async -> Bool;
    func join(session: String) async -> Bool;
}

public extension Session {
    public var player: String { self.transport.player };
}
