public enum MessageType: String, Codable {
    case ping;
    case playerReady;
}

public protocol Message: Codable {
    var type: MessageType { get }
}
