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
}
