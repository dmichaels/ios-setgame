public extension GameCenter {

    // TODO
    // Rethink this in terms of the ONLY consumer being the Session (protocol) implementation.
    // If we do it skillfully we may be able to have only a single Session implementation that
    // uses HttpTransport for our (Python) server based approach, and maybe eventually we will
    // have a GameCenter based Transport that requires no (or minimal) changes to that Session
    // implementation; time will tell.
    //
    public protocol Transport: AnyObject {
        var  player: String { get }
        func setup();
        func release();
        func bindSession(to: String);
        func bindSessionTentative(to: String);
    }
}
