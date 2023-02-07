import PhyKit
import Raylib

public protocol FlixGFX {
  var position: Vector3 { get set }
  var color: Color { get }
  var rotation: PHYQuaternion { get set }
  var constrainPlane: Bool { get }
  var wireframe: Bool { get }
  var wireframeColor: Color { get }
  var rigidbody: PHYRigidBody { get }
  // var forward: Vector3 { get }
  var _id: Int { get }

  func handleDraw()
  func insertIntoDrawList()
  func removeFromDrawList()
}