public struct PrefixableList {

    public private(set) var values: [String];
    public private(set) var prefixes: [String];
    private             var prefixLength: Int;
    private             let prefixLengthMin: Int;
    private             var selectedValue: String?;
    private static      let prefixLengthMin: Int = 4;

    public init(_ values: [String]? = [], prefixLengthMin: Int? = nil) {
        var values: [String] = values ?? [];
        self.prefixLengthMin = prefixLengthMin ?? PrefixableList.prefixLengthMin;
        let prefixLength: Int = PrefixableList.setup(&values, self.prefixLengthMin);
        self.values = values;
        self.prefixLength = prefixLength;
        self.prefixes = self.values.map { String($0.prefix(prefixLength)) }
    }

    public mutating func update(_ values: [String]?) {
        var values: [String] = values ?? [];
        let prefixLength: Int = PrefixableList.setup(&values, self.prefixLengthMin);
        self.values = values;
        self.prefixLength = prefixLength;
        self.prefixes = self.values.map { String($0.prefix(prefixLength)) }
        if (!self.contains(self.selectedValue)) {
            self.selectedValue = nil;
        }
    }

    public func contains(_ value: String?) -> Bool {
        guard let value, self.values.count > 0 else { return false }
        let values: [String] = self.values.filter { $0.hasPrefix(value) }
        return values.count == 1;
    }

    public func find(_ value: String?, prefix: Bool = false) -> String? {
        guard let value, self.values.count > 0 else { return nil }
        let values: [String] = self.values.filter { $0.hasPrefix(value) }
        return (values.count == 1) ? (prefix ? self.prefix(values[0]) : values[0]) : nil;
    }

    public func value(at index: Int, prefix: Bool = false) -> String? {
        return (index >= 0 && index < self.values.count) ? (prefix ? self.prefixes[index] : self.values[index]) : nil;
    }

    public mutating func select(_ value: String?) -> Bool {
        if let value: String = self.find(value) {
            self.selectedValue = value;
            return true;
        }
        return false;
    }

    public mutating func unselect() {
        self.selectedValue = nil;
    }

    public func selected(_ value: String?) -> Bool {
        guard let value, let selected = selectedValue, self.values.count > 0 else { return false }
        return (value == selected) || (value == self.prefix(selected));
    }

    public func selected(prefix: Bool = false) -> String? {
        if let value: String = self.selectedValue {
            return prefix
                   ? ((value.count == self.prefixLength)
                      ? value
                      : self.prefix(value))
                   : value;
        }
        return self.value(at: 0, prefix: prefix);
    }

    public var selected: String? {
        get { self.selected() }
        set { self.select(newValue) }
    }

    private func prefix(_ value: String) -> String {
        return String(value.prefix(self.prefixLength));
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
            if (!collision) { return prefixLength; } ; prefixLength += 1;
        }
    }
}
