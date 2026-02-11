public enum MessageType: String, Codable {
    case ping;
    case joinSession;
    case joinSessionAccepted;
    case playerReady;
}
