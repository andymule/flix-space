import PhyKit
import Raylib
import RaylibC
import simd

public class FlixCamera {
//   public var position: Vector3 = .zero
//   public var target: Vector3 = .zero
//   public var up: Vector3 = .init(x: 0, y: 1, z: 0)
//   public var fovy: Float = 45
//   public var zoom: Float = 1.0

  public var camera: Camera3D = Camera3D(
    position: Vector3(x: 0.0, y: 0.0, z: 10.0),
    target: Vector3(x: 0.0, y: 0.0, z: 0.0),
    up: Vector3(x: 0.0, y: 1.0, z: 0.0),
    fovy: 45.0,
    _projection: 0)  // CAMERA_PERSPECTIVE

    public func update( ship : FlixShip) {
        camera.position = Vector3(x: ship.position.x, y: ship.position.y, z: 10)
        camera.target = ship.position // + sqrt( ship.rigidbody.linearVelocity.vector3
        camera.fovy = min(max(45, ship.rigidbody!.linearVelocity.vector3.length * 5), 80)
    }
}
