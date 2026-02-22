import Foundation

public extension MultiPlayer.Dev {

    public class Poller {
        private let interval: UInt64;
        private var task: Task<Void, Never>? = nil;
        public private(set) var count: Int = 0;
        public init(milliseconds: Int = 1) {
            self.interval = UInt64(milliseconds * 1_000_000);
        }
        public func start(_ task: @escaping () async -> Void) {
            guard self.task == nil else { return }
            self.task = Task {
                while (!Task.isCancelled) {
                    self.count += 1;
                    await task();
                    try? await Task.sleep(nanoseconds: self.interval);
                }
            }
        }
        public func stop() {
            task?.cancel();
            task = nil;
        }
    }
}
