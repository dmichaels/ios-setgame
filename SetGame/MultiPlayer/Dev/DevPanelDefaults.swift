import SwiftUI

public extension MultiPlayer.Dev {

    public struct Defaults {
        public static let background: Color = Color(hex: 0x77BBAA);
        public static let foreground: Color = Color(hex: 0x226655);
        public static let fontSize: Int = 15;
        public static let separator: String = "|" // "\u{2756}";
        public static let emptySetChar: String = "∅";
        public static let checkChar: String = "✓";
        public static let xmarkChar: String = "✗";
        public static let leftArrowChar: String = "◀ ";
        public static let highlightColor: Color = Color(hex: 0x882211);
        public static let iconColor: Color = Color(hex: 0x0044BB);
        public static let iconSize: Int = 16;
    }
}
