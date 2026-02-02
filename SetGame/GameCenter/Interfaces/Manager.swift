import Foundation

public extension GameCenter
{
    public protocol Manager {
        var transport: Transport { get };
        var session: Session { get };
        func start() async;
        func stop();
    }
}
