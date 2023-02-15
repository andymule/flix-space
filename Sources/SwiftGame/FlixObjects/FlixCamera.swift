import PhyKit
import Raylib
import RaylibC
import simd

public class FlixCamera {
  static let viewType: Float = 1
  static let startZoom: Float = 45.0 //+ viewType * 30.0
  static let maxZoom: Float = 90 //+ viewType * 30

  public var camera: Camera3D = Camera3D(
    position: Vector3(x: 0.0, y: 0.0, z: 10.0),
    target: Vector3(x: 0.0, y: 0.0, z: 0.0),
    up: Vector3(x: 0.0, y: 1.0, z: 0.0),
    fovy: startZoom,
    _projection: Int32(viewType))  // 0 CAMERA_PERSPECTIVE, 1 ORTHO

  public func update(ship: FlixShip) {
    camera.position = Vector3(x: ship.position.x, y: ship.position.y, z: 10)
    camera.target = ship.position  // + sqrt( ship.rigidbody.linearVelocity.vector3
    camera.fovy = min(max(FlixCamera.startZoom, ship.rigidbody!.linearVelocity.vector3.length * 5), FlixCamera.maxZoom)
  }
}
