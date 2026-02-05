import Foundation

public extension GameCenter
{
    public protocol MessageSender {
        func send(message: Message, to: String);
    }

    public protocol MessageHandler: AnyObject {
        func handle(message: PingMessage);
        func handle(message: PlayerReadyMessage);
        func handle(message: NewGameMessage);
        func handle(message: FoundSetMessage);
        func handle(message: ConfirmedSetMessage);
    }

    protocol SessionHandler: MessageHandler, AnyObject {
        var  session: Session? { get set }
        func play();
    }
}

public extension GameCenter
{
    public protocol Transport: MessageSender, MessageHandler {
        var  player: String { get };
        var  handler: MessageHandler? { get set }
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
