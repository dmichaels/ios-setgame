import Foundation

public extension GameCenter
{
    public protocol XManager { // TODO: not using this yet anyways - maybe dont need
        var transport: Transport { get };
        var session: Session { get };
        func start() async;
        func stop();
    }
}
