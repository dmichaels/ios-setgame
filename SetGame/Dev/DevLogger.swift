import Foundation

public let  LOGGER: DevFileLogger = DevFileLogger(prefix: DevFileLogger.ID, file: "/tmp/APP_\(DevFileLogger.ID).LOG");
public func LOG(_ message: String) { LOGGER.log(message) }
public func DEB(_ message: String) { NSLog("XDEBUG-\(DevFileLogger.ID)> " + message) }

public final class DevFileLogger {

    public static let ID: String = String(SetGame.ID(size: 4).value);
    public static let instance = DevFileLogger();

    private let url: URL
    private let queue: DispatchQueue;
    private let prefix: String;

    public init(prefix: String = "", file: String? = nil, directory: URL? = nil, filename: String = "app.log") {
        let fm = FileManager.default;
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first!;
        self.queue = DispatchQueue(label: "file.logger.queue" + (!prefix.isEmpty ? prefix : ""));
        self.prefix = prefix;
        if let file: String = file {
            self.url = URL(fileURLWithPath: file)
        } else if let directory: URL = directory {
            self.url = directory.appendingPathComponent(filename);
        } else {
            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!;
            self.url = docs.appendingPathComponent(filename);
        }
        if !fm.fileExists(atPath: self.url.path) {
            fm.createFile(atPath: self.url.path, contents: nil);
        }
    }

    public func log(_ message: String) {
        let line = (!self.prefix.isEmpty ? "\(self.prefix) " : "") + "\(self.timestamp)> " + message + "\n";
        queue.async {
            if let handle = try? FileHandle(forWritingTo: self.url) {
                try? handle.seekToEnd();
                if let data = line.data(using: .utf8) {
                    try? handle.write(contentsOf: data);
                }
                try? handle.close();
            }
        }
    }

    public var path: String {
        return self.url.path;
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }()

    private var timestamp: String {
        return DevFileLogger.timeFormatter.string(from: Date());
    }
}
