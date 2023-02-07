import PhyKit
import Raylib
import RaylibC
import simd

public struct FlixBox: FlixGFX {
  public static let model: Model = Raylib.loadModelFromMesh(Raylib.genMeshCube(1, 1, 1))  //Raylib.loadModel("Resources/cube.obj")
  public var position: Vector3 {
    get {
      rigidbody.position.vector3
    }
    set {
      rigidbody.position = newValue.phyVector3
    }
  }
  public var size: Vector3
  public var color: Color
  public var rotation: PHYQuaternion {
    get {
      rigidbody.orientation
    }
    set {
      rigidbody.orientation = newValue
    }
  }
  public var constrainPlane: Bool = true
  public var wireframe: Bool = false
  public var wireframeColor: Color = .white

  public let rigidbody: PHYRigidBody
  public var forward: Vector3 {
    Vector3(x: 0, y: 0, z: 1).rotate(by: rotation.quaternion)
  }
  public init(pos: Vector3, size: Vector3, color: Color, isStatic: Bool) {
    self.size = size
    self.color = color
    let collisionShape = PHYCollisionShapeBox(width: size.x, height: size.y, length: size.z)
    self.rigidbody = PHYRigidBody(type: isStatic ? .static : .dynamic, shape: collisionShape)
    rigidbody.restitution = 1.0
    rigidbody.friction = 0.1
    rigidbody.linearDamping = 0.0
    rigidbody.angularDamping = 0.0
    rigidbody.position = pos.phyVector3
    rigidbody.isSleepingEnabled = false
    insertIntoDrawList()
  }

  public func handleDraw() {
    if constrainPlane {
      rigidbody.position.z = 0
    }
    let pos: Vector3 = rigidbody.position.vector3
    var (axis, angle) = rigidbody.orientation.vector4.toAxisAngle()
    angle = angle * 180 / Float.pi
    Raylib.drawModelEx(FlixBox.model, pos, axis, angle, size, color)
    if wireframe {
      Raylib.drawModelWiresEx(FlixBox.model, pos, axis, angle, size, wireframeColor)
    }
  }
}
