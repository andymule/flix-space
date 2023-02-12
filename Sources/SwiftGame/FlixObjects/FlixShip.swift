import PhyKit
import Raylib
import RaylibC
import simd

public class FlixShip: FlixObject, FlixInput, FlixCanShoot {
  private let bulletsMAX = 9999  //10
  private var bulletsActiveCount = 0
  private let recoilScale: Float = 0 //-0.2

  private let firingCooldown: Float = 0.1
  private var firingCooldownTimer: Float = 0.0

  // TODO need to change rigidbody scale if you change this w/ setter, and make sure the dictionary is updated to reflect new rigidbody
  // and old rigidbody is removed etc ok good job me you're doing great keep it up you're doing great you're doing great
  public let scale: Float

  // private let model: Model = Raylib.loadModel("Resources/ship.gltf")
  // cant get blender to export with correct orientation
  // private let boostmodel: Model = Raylib.loadModel("Resources/boost.gltf")
  private let boostModel: Model
  let boostTriangle: Triangle = Triangle(
    Vector3(x: -0.45, y: -0.65, z: 0),
    Vector3(x: 0.45, y: -0.65, z: 0),
    Vector3(x: 0, y: -1.5, z: 0)
  )
  private let brakeModel: Model
  let brakeTriangles: [Triangle] = [
    Triangle(
      Vector3(x: -0.5, y: 0.6, z: 0),
      Vector3(x: -0.9, y: -0.3, z: 0),
      Vector3(x: -0.2, y: -0.3, z: 0)
    ),
    Triangle(
      Vector3(x: 0.5, y: 0.6, z: 0),
      Vector3(x: 0.9, y: -0.3, z: 0),
      Vector3(x: 0.2, y: -0.3, z: 0)
    ),
  ]
  private var isBoosting = false
  private var isBraking = false

  public var lockRotationToZOnly: Bool = true

  public var forward: Vector3 {
    Vector3(x: 0, y: 1, z: 0).rotate(by: rotation.quaternion)
  }

  public init(pos: Vector3, scale: Float, color: Color, isStatic: Bool) {
    self.scale = scale
    boostModel = Raylib.loadModelFromMesh(Raylib.GenMeshFromTriangleArray([boostTriangle]))
    brakeModel = Raylib.loadModelFromMesh(Raylib.GenMeshFromTriangleArray(brakeTriangles))
    super.init()
    model = Raylib.loadModel("Resources/ship.gltf")
    self.color = color
    self.rigidbody = PHYRigidBodyFromRaylibModel(
      model: model!, scale: scale, isStatic: false, mass: scale, collisionType: .concave)

    rigidbody!.restitution = 0.3  //m_collisionFlags
    rigidbody!.friction = 0.1
    rigidbody!.linearDamping = 0.0
    rigidbody!.angularDamping = 0.0
    rigidbody!.position = pos.phyVector3
    rigidbody!.isSleepingEnabled = false
    // rigidbody.inter
    flixType = .ship
    insertIntoDrawList()
    insertIntoInputList()
  }

  override public func handleDraw() {
    if constrainPlane {
      rigidbody!.position.z = 0
    }
    if lockRotationToZOnly {
      rigidbody!.orientation = PHYQuaternion.euler(0, 0, rigidbody!.orientation.vector4.toEuler().z * 180 / Float.pi)
      rigidbody!.angularVelocity = PHYVector3(0, 0, rigidbody!.angularVelocity.z)
    }
    let pos: Vector3 = rigidbody!.position.vector3
    let (axis, angle) = rigidbody!.orientation.vector4.toAxisAngle()
    let angle2 = angle * 180 / Float.pi
    if isBraking {
      Raylib.drawModelEx(brakeModel, pos, axis, angle2, Vector3(scale), .orange)
    }
    Raylib.drawModelEx(model!, pos, axis, angle2, Vector3(x: scale * 0.8, y: scale, z: scale), color)
    if isBoosting {
      Raylib.drawModelEx(boostModel, pos, axis, angle2, Vector3(scale), .orange)
    }
    if wireframe {
      Raylib.drawModelWiresEx(model!, pos, axis, angle, Vector3(scale), wireframeColor)
    }
  }

  public func handleInput() {
    isBoosting = false
    isBraking = false
    if Raylib.isKeyDown(.right) {
      rigidbody!.angularVelocity += PHYVector3(x: 0, y: 0, z: -0.05)
    }
    if Raylib.isKeyDown(.left) {
      rigidbody!.angularVelocity += PHYVector3(x: 0, y: 0, z: 0.05)
    }
    if Raylib.isKeyDown(.up) {
      isBoosting = true
      rigidbody!.linearVelocity += forward.scale(0.05).phyVector3
    }
    if Raylib.isKeyDown(.down) {
      isBraking = true
      rigidbody!.linearVelocity += forward.scale(-0.05).phyVector3
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
    let bullet: FlixBullet = FlixBullet(
      pos: position, scale: 0.1, color: .cyan, owner: self, angularVel: rigidbody!.angularVelocity)
    bullet.rigidbody!.linearVelocity =
      rigidbody!.linearVelocity + forward.scale(6).phyVector3
    rigidbody!.linearVelocity = rigidbody!.linearVelocity + forward.scale(recoilScale).phyVector3  // recoil
    bullet.rigidbody!.position = position.phyVector3 + forward.scale(scale * 1.3).phyVector3
    bullet.rigidbody!.orientation = rotation
  }

  public func bulletDeathCallback() {
    bulletsActiveCount -= 1
  }
}
