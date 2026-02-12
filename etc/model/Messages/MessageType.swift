public extension GameCenter {

    public enum MessageType: String, Codable {
        case ping;
        case joinSession;
        case joinedSession;
        case updateSession;
    }
}
