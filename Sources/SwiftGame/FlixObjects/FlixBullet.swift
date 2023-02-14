import PhyKit
import Raylib
import RaylibC
import simd

public class FlixBullet: FlixObject {
  
  private var timeToLive: Float = 15.0
  let owner: FlixCanShoot
  var isExploding: Bool = false

  public static let model: Model = Raylib.loadModelFromMesh(Raylib.genMeshCube(1, 1, 1))  //Raylib.loadModel("Resources/cube.obj")
  public var scale: Float

  public init(pos: Vector3, scale: Float, color: Color, owner: FlixCanShoot, angularVel: PHYVector3 = PHYVector3(0, 0, 0)) {
    self.scale = scale
    self.owner = owner
    super.init()
    self.color = color
    let collisionShape: PHYCollisionShapeBox = PHYCollisionShapeBox(width: scale, height: scale, length: scale)
    self.rigidbody = PHYRigidBody(type: .dynamic(mass: 10.0), shape: collisionShape)
    rigidbody!.angularVelocity = angularVel
    rigidbody!.restitution = 0.0
    rigidbody!.friction = 1.0
    rigidbody!.linearDamping = 0.0
    rigidbody!.angularDamping = 0.0
    rigidbody!.position = pos.phyVector3
    rigidbody!.isSleepingEnabled = true
    flixType = .bullet
    insertIntoDrawList()
  }

  override public func handleDraw() {
    timeToLive -= FlixGame.deltaTime
    if isDying {
      return
    }
    if timeToLive <= 0 {
      die()
      return
    }
    if constrainPlane {
      rigidbody!.position.z = 0
    }
    let pos: Vector3 = rigidbody!.position.vector3
    var (axis, angle) = rigidbody!.orientation.vector4.toAxisAngle()
    angle = angle * 180 / Float.pi
    Raylib.drawModelEx(FlixBullet.model, pos, axis, angle, Vector3(scale), color)
    if wireframe {
      Raylib.drawModelWiresEx(FlixBullet.model, pos, axis, angle, Vector3(scale), wireframeColor)
    }
  }

  override public func explode(_ callbackData: FlixCallBackData? = nil) {
    if !isExploding {
      isExploding = true
      // FlixGame.score += 1
    }
    //callbackData as! Bool == true ? die(addPoints: true) : die()
    owner.bulletDeathCallback(addPoints: false)
    // let b = callbackData?.data[0] as! Int == 32
  }

  // override public func initCallbackDataFormat() {
  // callbackDataFormat.append(PHYRigidBody.self)
  // }
}
