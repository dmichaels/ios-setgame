public enum MessageType: String, Codable {
    case ping;
}

public protocol Message: Codable {
    var type: MessageType { get }
}
