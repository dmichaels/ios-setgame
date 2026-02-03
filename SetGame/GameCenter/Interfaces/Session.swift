import Foundation

public extension GameCenter
{
    public protocol Session: MessageSender {
        var  player: String { get };
        var  host: String { get };
        var  hosting: Bool { get };
        var  players: [String] { get };
        func start() async -> Bool;
        func bind(to: MessageHandler);
    }
}
