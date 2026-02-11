public extension GameCenter {

    public protocol Transport: AnyObject {
        var  player: String { get }
        func setup();
        func release();
    }
}
