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

public extension XGameCenter.Message
{
    public func serialize() -> Data? {
        do { return try JSONEncoder().encode(self); } catch { return nil; }
    }

    public var json: [String: Any]? {
        if let data = self.serialize(),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            return json;
        }
        return nil;
    }
}
