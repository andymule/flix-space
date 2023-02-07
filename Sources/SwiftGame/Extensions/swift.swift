public extension Array where Element: Equatable {
  mutating func removeEqualItems(_ item: Element) {
    self = self.filter { (currentItem: Element) -> Bool in
      return currentItem != item
    }
  }

  mutating func removeFirstEqualItem(_ item: Element) {
    guard var currentItem = self.first else { return }
    var index = 0
    while currentItem != item {
      index += 1
      currentItem = self[index]
    }
    self.remove(at: index)
  }
}
