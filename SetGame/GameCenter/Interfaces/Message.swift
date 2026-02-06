import Foundation

public extension GameCenter
{
    public enum MessageType: String, Codable {
        case ping;
        case playerReady;
        case newGame;
        case foundSet;
        case foundSetTooLate;
        case confirmedSet;
    }

    public protocol Message: Codable {
        var  type: MessageType { get };
        var  json: [String: Any]? { get };
    }
}

public extension GameCenter.Message
{
    public var json: [String: Any]? {
        if let data = try? JSONEncoder().encode(self),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            return json;
        }
        return nil;
    }
}
