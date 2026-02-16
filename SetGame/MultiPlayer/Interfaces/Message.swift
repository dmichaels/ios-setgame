import Foundation

public extension MultiPlayer {

    public protocol Message: Codable, Identifiable where ID == UUID {
        var id: UUID { get }
        var type: MessageType { get }
        var json: [String: Any]? { get };
    }
}

public extension MultiPlayer.Message {
    public var json: [String: Any]? {
        if let data = try? JSONEncoder().encode(self),
        let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            return json;
        }
        return nil;
    }
}
