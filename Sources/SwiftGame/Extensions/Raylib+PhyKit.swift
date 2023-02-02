import PhyKit
import Raylib
import RaylibC
import simd

extension PHYVector3 {
  public var vector3: Vector3 {
    Vector3(x: x, y: y, z: z)
  }
  public var vector2: Vector2 {
    Vector2(x: x, y: y)
  }
}

extension Vector3 {
  public var phyVector3: PhyKit.PHYVector3 {
    PHYVector3(x: x, y: y, z: z)
  }

  init (_ uniform: Float) {
    self.init(x: uniform, y: uniform, z: uniform)
  }

  static func random(in range: ClosedRange<Float>) -> Vector3 {
    Vector3(
      x: Float.random(in: range),
      y: Float.random(in: range),
      z: Float.random(in: range)
    )
  }
}

extension Vector2 {
  public var phyVector3: PhyKit.PHYVector3 {
    PHYVector3(x: x, y: y, z: 0)
  }
}

extension PHYQuaternion {
  public var vector4: Vector4 {
    Vector4(x: x, y: y, z: z, w: w)
  }
  public var quaternion: Quaternion {
    Vector4(x: x, y: y, z: z, w: w)
  }
}

extension Quaternion {
  public var phyQuat: PHYQuaternion {
    PHYQuaternion(x: x, y: y, z: z, w: w)
  }
}