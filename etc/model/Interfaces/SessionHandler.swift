public protocol SessionHandler: MessageHandler, AnyObject {
    var  session: Session? { get set }
}
