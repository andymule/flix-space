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
  var forward: Vector3 { get }

  func handleDraw()
  func insertIntoDrawList() 
}

extension FlixGFX {
  public func insertIntoDrawList() {
    FlixGame.drawList.append(self)
    FlixGame.physicsWorld.add(self.rigidbody)
  }
}