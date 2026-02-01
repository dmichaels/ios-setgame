import Foundation

public extension XGameCenter
{
    public protocol MessageSender {
        func send(message: Message);
    }

    public protocol MessageHandler {
        func handle(message: PingMessage);
        var  sender: MessageSender? { get set }
    }
}

public extension XGameCenter.MessageHandler
{
    public var sender: XGameCenter.MessageSender? { get { nil } set {} }
}

public extension XGameCenter
{
    public protocol Transport: MessageSender, MessageHandler {
        var  player: String { get };
        func start();
        func stop();
    }

    public protocol Session{
        var player: String { get };
        var host: String { get };
        var hosting: Bool { get };
        var players: [String] { get };
    }

    public protocol Manager{
        var transport: Transport { get };
        var session: Session { get };
        func start() async;
        func stop();
    }
}
