import Foundation

/// String extension conveniences.
///
extension String {

    public subscript (characterIndex: Int) -> Character {
        return self[index(startIndex, offsetBy: characterIndex)]
    }

    public func split(delimiters: String = ",") -> [String] {
        self.components(separatedBy: CharacterSet(charactersIn: delimiters))
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    public func substring(from start: Int, length: Int) -> String {
        guard start >= 0, length >= 0, start < self.count else { return "" }
        let start = self.index(self.startIndex, offsetBy: start)
        let end = self.index(start, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex;
        return String(self[start..<end])
    }
}
