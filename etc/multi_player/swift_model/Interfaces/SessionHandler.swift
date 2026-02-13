public extension GameCenter {

    public protocol SessionHandler: MessageHandler {
        var  session: Session? { get set }
    }
}
