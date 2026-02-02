import Foundation

public extension GameCenter
{
    public protocol Session {
        var player: String { get };
        var host: String { get };
        var hosting: Bool { get };
        var players: [String] { get };
        func start(bind: MessageHandler) async -> Bool;
    }
}
