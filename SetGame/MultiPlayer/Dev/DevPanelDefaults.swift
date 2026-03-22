import SwiftUI

public extension MultiPlayer.Dev {

    public struct Defaults {
        public static let background: Color = Color(hex: 0x77BBAA);
        public static let backgroundParent: Color = Color(hex: 0xDCEEE4);
        public static let foreground: Color = Color(hex: 0x226655);
        public static let fontSize: Int = 16;
        public static let separator: String = "|" // "\u{2756}";
        public static let emptySetChar: String = "∅";
        public static let checkChar: String = "✓";
        public static let xmarkChar: String = "✗";
        public static let leftArrowChar: String = "◀";
        public static let starChar: String = "★";
        public static let highlightColor: Color = Color(hex: 0x882211); // dark red
        public static let iconColor: Color = Color(hex: 0x0044BB);      // dark blue
        public static let iconSize: Int = 20;
        public static let padding: Padding = Padding(leading: 8, trailing: 8, top: 4, bottom: 4);
    }
}
