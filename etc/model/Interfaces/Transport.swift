public protocol Transport: AnyObject /*MessageHandler*/ {
    var  player: String { get }
    func setup();
    func release();
}
