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
        var  json: [String: Any]? { get };
        // TEMPORARY WHILE MIGRATING TO THIS ...
        func serialize() -> Data?
        // ... END TEMPORARY WHILE MIGRATING TO THIS
    }
}

public extension XGameCenter.Message
{
    public init?(_ data: Data?) {
         guard let message = XGameCenter.MessageConversion.toMessage(data: data) as? Self else { return nil }
         self = message;
    }

    public var json: [String: Any]? {
        if let data = self.serialize(),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            return json;
        }
        return nil;
    }

    // TEMPORARY WHILE MIGRATING TO THIS ...
    public func serialize() -> Data? {
    // private func serialize() -> Data? {
    // ... END TEMPORARY WHILE MIGRATING TO THIS
        do { return try JSONEncoder().encode(self); } catch { return nil; }
    }
}
