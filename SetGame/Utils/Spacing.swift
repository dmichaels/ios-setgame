import Foundation
import SwiftUI

public struct Padding {

    public static let fallback: Padding = Padding();

    public var leading:  CGFloat { CGFloat(self._leading  ?? 0) }
    public var trailing: CGFloat { CGFloat(self._trailing ?? 0) }
    public var top:      CGFloat { CGFloat(self._top      ?? 0) }
    public var bottom:   CGFloat { CGFloat(self._bottom   ?? 0) }

    private let _leading:  Int?;
    private let _trailing: Int?;
    private let _top:      Int?;
    private let _bottom:   Int?;

    public init(leading: Int? = nil, trailing: Int? = nil, top: Int? = nil, bottom: Int? = nil) {
        self._leading  = leading;
        self._trailing = trailing;
        self._top      = top;
        self._bottom   = bottom;
    }

    public init(_ value: Padding?, _ fallback: Padding?) {
        self._leading  = value?._leading  ?? fallback?._leading;
        self._trailing = value?._trailing ?? fallback?._trailing;
        self._top      = value?._top      ?? fallback?._top;
        self._bottom   = value?._bottom   ?? fallback?._bottom;
    }

    public init(horizontal: Int? = nil, vertical: Int?) {
        self.init(leading: horizontal, trailing: horizontal, top: vertical, bottom: vertical);
    }
}

public typealias Margin = Padding;

public struct Style {
    public let size:       Int?;
    public let padding:    Padding?;
    public let margin:     Margin?;
    public let weight:     Font.Weight?;
    public let foreground: Color?;
    public let background: Color?;
    public let disabled:   Bool;
    public init(size: Int? = nil, padding: Padding? = nil, margin: Margin? = nil, weight: Font.Weight? = nil,
                foreground: Color? = nil, background: Color? = nil, disabled: Bool = false) {
        self.size = size;
        self.padding = padding;
        self.margin = margin;
        self.weight = weight;
        self.foreground = foreground;
        self.background = background;
        self.disabled = disabled;
    }
}

public extension View {

    public func padding(_ padding: Padding) -> some View {
        self.padding(.leading,  padding.leading)
            .padding(.trailing, padding.trailing)
            .padding(.top,      padding.top)
            .padding(.bottom,   padding.bottom)
    }

    public func margin(_ margin: Margin) -> some View {
        self.padding(.leading,  margin.leading)
            .padding(.trailing, margin.trailing)
            .padding(.top,      margin.top)
            .padding(.bottom,   margin.bottom)
    }
}
