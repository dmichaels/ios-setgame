import Foundation

public extension XGameCenter
{
    public enum MessageType: String, Codable {
        case ping;
        case playerReady;
        case newGame;
        case foundSet;
        case confirmedSet;
    }

    public protocol Message: Codable {
        var  type: MessageType { get };
        var  player: String { get };
        func serialize() -> Data?;
        var  json: [String: Any]? { get };
    }
}
