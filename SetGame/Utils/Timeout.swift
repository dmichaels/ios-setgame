import Foundation

public struct TimeoutError: Error {}
public func withTimeout<T>(seconds: TimeInterval, operation: @escaping @Sendable () async throws -> T) async throws -> T {
    //
    // This is mostly courtesy of ChatGPT; should understand more.
    //
    return try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask {
            return try await operation();
        }
        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000));
            throw TimeoutError();
        }
        let result = try await group.next()!; // this throws when timeout wins
        group.cancelAll();
        return result;
    }
}
