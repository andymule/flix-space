import PhyKit
import Raylib
import RaylibC
import simd

public class FlixBox: FlixObject {
  // public static let staticModel: Model = Raylib.loadModelFromMesh(Raylib.genMeshCube(1, 1, 1))
  public var size: Vector3 = .zero

  // TODO restore size
  public init(
    pos: Vector3, size size2: Vector3, color: Color, isStatic: Bool, flixType: FlixObjectType = .asteroid,
    autoInsertIntoList: Bool = true
  ) {
    self.size = .one  // size
    super.init()
    model = Raylib.loadModelFromMesh(Raylib.genMeshCube(self.size.x, self.size.y, self.size.z))
    self.color = color
    let collisionShape: PHYCollisionShapeBox = PHYCollisionShapeBox(width: self.size.x, height: self.size.y, length: self.size.z)
    let mass: Float = size.x + size.y + size.z
    self.rigidbody = PHYRigidBody(type: isStatic ? .static : .dynamic(mass: mass), shape: collisionShape)
    rigidbody!.restitution = 1.0
    rigidbody!.friction = 0.1
    rigidbody!.linearDamping = 0.0
    rigidbody!.angularDamping = 0.0
    rigidbody!.position = pos.phyVector3
    rigidbody!.isSleepingEnabled = false
    self.flixType = flixType
    if autoInsertIntoList {
      insertIntoDrawList()
    }
  }

  override public func handleDraw() {
    if isDying {
      return
    }
    if constrainPlane {
      rigidbody!.position.z = 0
    }
    let pos: Vector3 = rigidbody!.position.vector3
    var (axis, angle) = rigidbody!.orientation.vector4.toAxisAngle()
    angle = angle * 180 / Float.pi
    Raylib.drawModelEx(model!, pos, axis, angle, size, color)
    if wireframe {
      Raylib.drawModelWiresEx(model!, pos, axis, angle, size, wireframeColor)
    }
  }

  override public func explode() {
    if isDying {
      return
    }
    isDying = true
    if flixType == .asteroid {
      // FlixGame.score += 1
      _ = FlixMeshExplosion(model: model!, startingBody: rigidbody!, color: color, size: size)
    }
    removeFromDrawList()
  }
}
