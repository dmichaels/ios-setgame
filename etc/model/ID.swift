import CryptoKit
import Foundation

/// This ID type is a unique ID for debugging; it is a UUID (or hash thereof) which
/// acts like a String; it can be short (6 characters); or very short (4 characters);
/// or any size really in between 1 and 32 inclusive.
///
public struct ID: ExpressibleByStringLiteral, CustomStringConvertible, Equatable, Hashable {

    public let value: String;

    public init(size: Int? = nil) {
        let size: Int = min(max(size ?? 32, 1), 32);
        let uuid: String = UUID().uuidString.replacingOccurrences(of: "-", with: "").uppercased();
        self.value = (size == 32) ? uuid : ID.shorten(uuid, size: size);
    }

    public init(short: Bool)     { if (short)     { self.init(size: 6) } else { self.init() } }
    public init(veryshort: Bool) { if (veryshort) { self.init(size: 4) } else { self.init() } }

    public init(stringLiteral value: String) { self.value = value }
    public var description: String { self.value }

    private static func shorten(_ uuid: String, size: Int = 6) -> String {
        return String(SHA256.hash(data: Data(uuid.utf8))
                   .compactMap { String(format: "%02X", $0) }.joined().prefix(size));
    }
}
