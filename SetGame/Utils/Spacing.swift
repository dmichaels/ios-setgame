import Foundation

public struct Spacing {

    public static let defaults: Spacing = Spacing();

    public init(margin: Margin, padding: Padding? = nil) {
        self.padding = padding ?? Padding();
        self.margin  = margin;
    }

    public init(padding: Padding, margin: Margin? = nil) {
        self.padding = padding;
        self.margin  = margin ?? Margin();
    }

    public init(leading:       Int? = nil, trailing:       Int? = nil, 
                top:           Int? = nil, bottom:         Int? = nil, 
                leadingMargin: Int? = nil, trailingMargin: Int? = nil, 
                topMargin:     Int? = nil, bottomMargin:   Int? = nil) {
        self.padding = Padding(leading: leading,       trailing: trailing,
                               top:     top,           bottom:   bottom);
        self.margin  = Margin (leading: leadingMargin, trailing: trailingMargin,
                               top:     topMargin,     bottom:   bottomMargin);
    }

    public init(horizontal:       Int? = nil, top:       Int? = nil, bottom:       Int? = nil, 
                horizontalMargin: Int? = nil, topMargin: Int? = nil, bottomMargin: Int? = nil) {
        self.padding = Padding(leading: horizontal,       trailing: horizontal,
                               top:     top,              bottom:   bottom);
        self.margin  = Margin (leading: horizontalMargin, trailing: horizontalMargin,
                               top:     topMargin,        bottom:   bottomMargin);
    }

    public init(leading:       Int? = nil, trailing:       Int? = nil, vertical:       Int? = nil,
                leadingMargin: Int? = nil, trailingMargin: Int? = nil, verticalMargin: Int? = nil) {
        self.padding = Padding(leading: leading,        trailing: trailing,
                               top:     vertical,       bottom:   vertical);
        self.margin  = Margin (leading: leadingMargin,  trailing: trailingMargin,
                               top:     verticalMargin, bottom:   verticalMargin);
    }

    public init(horizontal:       Int? = nil, vertical:       Int? = nil, 
                horizontalMargin: Int? = nil, verticalMargin: Int? = nil) {
        self.padding = Padding(horizontal: horizontal,       vertical: vertical);
        self.margin  = Margin (horizontal: horizontalMargin, vertical: verticalMargin);
    }

    public let padding: Padding;
    public let margin:  Margin;
}

public struct Padding {

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

    public init(_ value: Padding, _ defaults: Padding) {
        self._leading  = value._leading  ?? defaults._leading;
        self._trailing = value._trailing ?? defaults._trailing;
        self._top      = value._top      ?? defaults._top;
        self._bottom   = value._bottom   ?? defaults._bottom;
    }

    public init(horizontal: Int? = nil, vertical: Int?) {
        self.init(leading: horizontal, trailing: horizontal, top: vertical, bottom: vertical);
    }
}

public typealias Margin = Padding;
