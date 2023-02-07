import PhyKit
import Raylib
import RaylibC
import simd

public class FlixShip: FlixObject, FlixInput, FlixCanShoot {
  private let bulletsMAX = 10
  private var bulletsActiveCount = 0

  private let firingCooldown: Float = 0.2
  private var firingCooldownTimer: Float = 0.0

  private let model: Model = Raylib.loadModel("Resources/ship.gltf")
  public let scale: Float  // change rigidbody scale if you change this w/ getter setter
  public var lockRotationToZOnly: Bool = true

  public var forward: Vector3 {
    Vector3(x: 0, y: 1, z: 0).rotate(by: rotation.quaternion)
  }

  public init(pos: Vector3, scale: Float, color: Color, isStatic: Bool) {
    self.scale = scale
    super.init()
    self.color = color
    self.rigidbody = PHYRigidBodyFromRaylibModel(
      model: model, scale: scale, isStatic: false, mass: scale, collisionType: .concave)

    rigidbody.restitution = 0.3
    rigidbody.friction = 0.1
    rigidbody.linearDamping = 0.0
    rigidbody.angularDamping = 0.0
    rigidbody.position = pos.phyVector3
    rigidbody.isSleepingEnabled = false
    // rigidbody.isCollisionEnabled
    insertIntoDrawList()
    insertIntoInputList()
  }

  override public func handleDraw() {

    if constrainPlane {
      rigidbody.position.z = 0
    }
    if lockRotationToZOnly {
      rigidbody.orientation = PHYQuaternion.euler(0, 0, rigidbody.orientation.vector4.toEuler().z * 180 / Float.pi)
      rigidbody.angularVelocity = PHYVector3(0, 0, rigidbody.angularVelocity.z)
    }
    let pos: Vector3 = rigidbody.position.vector3
    var (axis, angle) = rigidbody.orientation.vector4.toAxisAngle()
    angle = angle * 180 / Float.pi
    Raylib.drawModelEx(model, pos, axis, angle, Vector3(scale), color)
    if wireframe {
      Raylib.drawModelWiresEx(model, pos, axis, angle, Vector3(scale), wireframeColor)
    }
  }

  public func handleInput() {
    if Raylib.isKeyDown(.right) {
      rigidbody.angularVelocity += PHYVector3(x: 0, y: 0, z: -0.05)
    }
    if Raylib.isKeyDown(.left) {
      rigidbody.angularVelocity += PHYVector3(x: 0, y: 0, z: 0.05)
    }
    if Raylib.isKeyDown(.up) {
      rigidbody.linearVelocity += forward.scale(0.05).phyVector3
    }
    if Raylib.isKeyDown(.down) {
      rigidbody.linearVelocity += forward.scale(-0.05).phyVector3  //ship.rotation.direction.vector3.scale(-0.1).phyVector3
    }
    firingCooldownTimer -= FlixGame.deltaTime
    if Raylib.isKeyDown(.space) {
      fire()
    }
  }

  public func fire() {
    if bulletsActiveCount >= bulletsMAX || firingCooldownTimer > 0 {
      return
    }
    firingCooldownTimer = firingCooldown
    bulletsActiveCount += 1
    let bullet: FlixBullet = FlixBullet(pos: position, scale: 0.1, color: .red, owner: self)
    bullet.rigidbody.linearVelocity =
      rigidbody.linearVelocity + forward.scale(6).phyVector3
    rigidbody.linearVelocity = rigidbody.linearVelocity + forward.scale(-0.5).phyVector3 // recoil
    bullet.rigidbody.position = position.phyVector3 + forward.scale(scale * 1.5).phyVector3
    bullet.rigidbody.orientation = rotation
  }

  public func bulletDeathCallback() {
    bulletsActiveCount -= 1
  }
}
