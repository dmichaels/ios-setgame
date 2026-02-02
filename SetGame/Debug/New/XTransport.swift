import Foundation

public extension XGameCenter
{
    public protocol MessageSender {
        func send(message: Message);
    }

    public protocol MessageHandler: AnyObject {
        var  sender: MessageSender? { get set }
        func handle(message: PingMessage);
        func handle(message: PlayerReadyMessage);
        func handle(message: NewGameMessage);
        func handle(message: FoundSetMessage);
        func handle(message: ConfirmedSetMessage);
    }
}

public extension XGameCenter
{
    public protocol Transport: MessageSender, MessageHandler {
        var  player: String { get };
        func start();
        func stop();
        func bind(to: MessageHandler);
    }
}
