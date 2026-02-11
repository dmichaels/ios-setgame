public protocol Message: Codable {
    var type: MessageType { get }
}
