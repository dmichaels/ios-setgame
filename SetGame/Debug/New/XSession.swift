import Foundation

public extension XGameCenter
{
    public protocol Session {
        var player: String { get };
        var host: String { get };
        var hosting: Bool { get };
        var players: [String] { get };
    }
}
