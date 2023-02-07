import PhyKit
import Raylib
import RaylibC
import simd

public class FlixBullet: FlixObject {
  private var timeToLive: Float = 5.0

  public static let model: Model = Raylib.loadModelFromMesh(Raylib.genMeshCube(1, 1, 1))  //Raylib.loadModel("Resources/cube.obj")
  public var scale: Float

  public init(pos: Vector3, scale: Float, color: Color) {
    self.scale = scale
    super.init()
    self.color = color
    let collisionShape = PHYCollisionShapeBox(width: scale, height: scale, length: scale)
    self.rigidbody = PHYRigidBody(type: .dynamic, shape: collisionShape)
    rigidbody.restitution = 0.0
    rigidbody.friction = 1.0
    rigidbody.linearDamping = 0.0
    rigidbody.angularDamping = 0.0
    rigidbody.position = pos.phyVector3
    rigidbody.isSleepingEnabled = false
    insertIntoDrawList()
  }

  override public func handleDraw() {
    timeToLive -= FlixGame.deltaTime
    if timeToLive <= 0 {
      removeFromDrawList()
      return
    }
    if constrainPlane {
      rigidbody.position.z = 0
    }
    let pos: Vector3 = rigidbody.position.vector3
    var (axis, angle) = rigidbody.orientation.vector4.toAxisAngle()
    angle = angle * 180 / Float.pi
    Raylib.drawModelEx(FlixBullet.model, pos, axis, angle, Vector3(scale), color)
    if wireframe {
      Raylib.drawModelWiresEx(FlixBullet.model, pos, axis, angle, Vector3(scale), wireframeColor)
    }
  }
}
