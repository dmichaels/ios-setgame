public protocol Session: AnyObject {
    var  player: String { get }
    var  transport: Transport { get }
    func send(message: Message, to: String);
    func setup() async;
}

public extension Session {
    public var player: String { self.transport.player };
}
