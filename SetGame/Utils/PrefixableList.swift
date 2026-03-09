public struct PrefixableList {

    public private(set) var values: [String];
    public private(set) var prefixes: [String];
    public private(set) var prefixLength: Int;
    public private(set) var selected: String?;
    private static      let prefixLengthMin: Int = 4;

    public init(_ values: [String]? = [], _ prefixLengthMin: Int? = nil) {
        var values: [String] = values ?? [];
        let prefixLength: Int = PrefixableList.setup(&values, PrefixableList.prefixLengthMin);
        self.values = values;
        self.prefixLength = prefixLength;
        self.prefixes = self.values.map { String($0.prefix(prefixLength)) }
        self.selected = values.count > 0 ? values[0] : nil;
    }

    public mutating func update(_ values: [String]?) {
        var values: [String] = values ?? [];
        let prefixLength: Int = PrefixableList.setup(&values, PrefixableList.prefixLengthMin);
        self.values = values;
        self.prefixLength = prefixLength;
        self.prefixes = self.values.map { String($0.prefix(prefixLength)) }
        if (!self.select(self.selected)) {
            self.selected = values.count > 0 ? values[0] : nil;
        }
    }

    public func contains(_ value: String?) -> Bool {
        guard let value else { return false }
        if (value.count == self.prefixLength) {
            return self.prefixes.contains(value);
        }
        else if (self.values.contains(value)) {
            return true;
        }
        else {
            let values: [String] = self.values.filter { $0.hasPrefix(value) }
            return values.count == 1;
        }
    }

    public func find(_ value: String?, prefix: Bool = false) -> String? {
        guard let value else { return nil }
        if (value.count == self.prefixLength) {
            if let index: Int = self.prefixes.firstIndex(of: value) {
                return prefix ? value : self.values[index];
            }
            else {
                return nil;
            }
        }
        else if (self.values.contains(value)) {
            return prefix ? String(value.prefix(self.prefixLength)) : value;
        }
        else {
            let values: [String] = self.values.filter { $0.hasPrefix(value) }
            return (values.count == 1) ? (prefix ? String(values[0].prefix(self.prefixLength)) : values[0]) : nil;
        }
    }

    public func value(at index: Int, prefix: Bool = false) -> String? {
        return (index >= 0 && index < self.values.count) ? (prefix ? self.prefixes[index] : self.values[index]) : nil;
    }

    public func first(prefix: Bool = false) -> String? {
        return self.value(at: 0, prefix: prefix);
    }

    public var first: String? {
        return self.value(at: 0);
    }

    public mutating func select(_ value: String?) -> Bool {
        if let value: String = self.find(value) {
            self.selected = value;
            return true;
        }
        return false;
    }

    public func selected(prefix: Bool = false) -> String? {
        if let value: String = self.selected {
            return prefix
                   ? ((value.count == self.prefixLength)
                      ? value
                      : String(value.prefix(self.prefixLength)))
                   : value;
        }
        return nil;
    }

    public func selected(_ value: String?) -> Bool {
        if let value: String = value {
            if let selected: String = self.selected {
                return (value == selected) || (value == selected.prefix(self.prefixLength));
            }
        }
        else if (self.selected == nil) {
            return true;
        }
        return false;
    }

    public mutating func unselect() {
        self.selected = nil;
    }

    // Ensures that the values in the given array of strings are unique, removing
    // any duplicates; and returns the minimum string prefix length which can be
    // used to consider any string within the list to be unique, using the given
    // length as the default minimum value for this. N.B. ChatGPT assisted code.
    // 
    private static func setup(_ values: inout [String], _ prefixLengthMin: Int? = nil) -> Int {
        var prefixLength: Int = max(prefixLengthMin ?? PrefixableList.prefixLengthMin, 1);
        guard !values.isEmpty else { return prefixLength }
        var valuesSeen: Set<String> = Set<String>(minimumCapacity: values.count);
        for (i, s) in values.enumerated() {
            if (!valuesSeen.insert(s).inserted) {
                var prefixes: Array<String> = Array(values.prefix(i));
                var prefixesSeen: Set<String> = Set(prefixes);
                for value in values[i...] {
                    if (prefixesSeen.insert(value).inserted) { prefixes.append(value); }
                }
                values = prefixes; break;
            }
        }
        var prefixesSeen: Set<Substring> = Set<Substring>(minimumCapacity: values.count);
        while (true) {
            prefixesSeen.removeAll(keepingCapacity: true); var collision: Bool = false;
            for item in values {
                let prefix: Substring = item.prefix(prefixLength);
                if (!prefixesSeen.insert(prefix).inserted) { collision = true; break; }
            }
            if (!collision) { return prefixLength; }
            prefixLength += 1;
        }
    }
}
