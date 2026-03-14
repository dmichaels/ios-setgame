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

    public init(horizontal: Int? = nil, leading: Int? = nil, trailing: Int? = nil,
                vertical:   Int? = nil, top:     Int? = nil, bottom:   Int? = nil) {
        self._leading  = leading  ?? horizontal;
        self._trailing = trailing ?? horizontal;
        self._top      = top      ?? vertical;
        self._bottom   = bottom   ?? vertical;
    }

    public init(_ value: Int? = nil) {
        self._leading  = value;
        self._trailing = value;
        self._top      = value;
        self._bottom   = value;
    }

    public init(_ value: Padding?, fallback: Padding?) {
        self._leading  = value?._leading  ?? fallback?._leading;
        self._trailing = value?._trailing ?? fallback?._trailing;
        self._top      = value?._top      ?? fallback?._top;
        self._bottom   = value?._bottom   ?? fallback?._bottom;
    }

    public init(_ value: Padding) {
        self = value;
    }
}

public typealias Margins = Padding;

public extension View {

    public func padding(_ padding: Padding) -> some View {
        self.padding(.leading,  padding.leading)
            .padding(.trailing, padding.trailing)
            .padding(.top,      padding.top)
            .padding(.bottom,   padding.bottom)
    }

    public func margins(_ margins: Margins) -> some View {
        self.padding(.leading,  margins.leading)
            .padding(.trailing, margins.trailing)
            .padding(.top,      margins.top)
            .padding(.bottom,   margins.bottom)
    }
}
