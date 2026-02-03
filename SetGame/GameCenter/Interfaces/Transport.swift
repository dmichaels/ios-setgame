import Foundation

public extension GameCenter
{
    public protocol MessageSender {
        func send(message: Message);
    }

    public protocol MessageHandler: AnyObject {
        func handle(message: PingMessage);
        func handle(message: PlayerReadyMessage);
        func handle(message: NewGameMessage);
        func handle(message: FoundSetMessage);
        func handle(message: ConfirmedSetMessage);
    }

    protocol SessionMessageHandler: MessageHandler, AnyObject {
        var  session: Session? { get set }
    }
}

public extension GameCenter
{
    public protocol Transport: MessageSender, MessageHandler {
        var  handler: MessageHandler? { get set }
        var  player: String { get };
        func start();
        func stop();
        func bind(to: MessageHandler);
    }
}

public extension GameCenter.Transport {
    public func bind(to handler: GameCenter.MessageHandler) {
        self.handler = handler;
    }
}
