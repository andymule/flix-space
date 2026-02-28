extension Array where Element: Equatable {
    public mutating func removeEqualItems(_ item: Element) {
        self = self.filter { $0 != item }
    }

    public mutating func removeFirstEqualItem(_ item: Element) {
        guard let index = firstIndex(of: item) else { return }
        remove(at: index)
    }

    /// O(1) removal by swapping with last element. Does not preserve order.
    public mutating func swapRemove(_ item: Element) {
        guard let index = firstIndex(of: item) else { return }
        if index == count - 1 {
            removeLast()
        } else {
            swapAt(index, count - 1)
            removeLast()
        }
    }
}

extension FixedWidthInteger {
    public var int: Int { Int(self) }
}

extension FloatingPoint {
    func isNearlyEqual(to value: Self) -> Bool {
        return abs(self - value) <= .ulpOfOne
    }

    func roundedTenths() -> Self {
        (self * 10).rounded() / 10
    }

    public var rad2deg: Self { self * 180 / .pi }
    public var deg2rad: Self { self * .pi / 180 }
}

extension Float {
    public func roundedTenths() -> Self {
        (self * 10).rounded() / 10
    }
}
