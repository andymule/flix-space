import PhyKit
import Raylib
import RaylibC
import simd

public class FlixBox: FlixObject {
  public static let model: Model = Raylib.loadModelFromMesh(Raylib.genMeshCube(1, 1, 1))
  public var size: Vector3 = .zero

  public init(pos: Vector3, size: Vector3, color: Color, isStatic: Bool, flixType: FlixObjectType = .asteroid, autoInsertIntoList: Bool = true) {
    self.size = size
    super.init()
    self.color = color
    let collisionShape: PHYCollisionShapeBox = PHYCollisionShapeBox(width: size.x, height: size.y, length: size.z)
    let mass: Float = size.x + size.y + size.z
    self.rigidbody = PHYRigidBody(type: isStatic ? .static : .dynamic(mass: mass), shape: collisionShape)
    rigidbody.restitution = 1.0
    rigidbody.friction = 0.1
    rigidbody.linearDamping = 0.0
    rigidbody.angularDamping = 0.0
    rigidbody.position = pos.phyVector3
    rigidbody.isSleepingEnabled = false
    self.flixType = flixType
    if autoInsertIntoList {
      insertIntoDrawList()
    }
  }

  override public func handleDraw() {
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

  override public func explode() {
    _ = FlixMeshExplosion(
      model: FlixBox.model, startingVel: rigidbody.linearVelocity.vector3, centerPos: rigidbody.position.vector3, color: color)
    removeFromDrawList()
  }
}
