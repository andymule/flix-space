extension Array where Element: Equatable {
  public mutating func removeEqualItems(_ item: Element) {
    self = self.filter { (currentItem: Element) -> Bool in
      return currentItem != item
    }
  }

  public mutating func removeFirstEqualItem(_ item: Element) {
    guard var currentItem: Element = self.first else { return }
    var index: Int = 0
    while currentItem != item {
      index += 1
      currentItem = self[index]
    }
    self.remove(at: index)
  }
}

extension Int32 {
  public var int: Int { Int(self) }
}