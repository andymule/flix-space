import Raylib

public extension ConfigFlags {
    // enable bitwise or
    static func | (lhs: ConfigFlags, rhs: ConfigFlags) -> ConfigFlags {
        ConfigFlags(rawValue: lhs.rawValue | rhs.rawValue)
    }
}

public extension Mesh {
  func indexAt(_ pos: Int) -> Int {
    Int(self.indices[pos])
  }
}