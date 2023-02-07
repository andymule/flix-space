import PhyKit
import Raylib
import RaylibC
import simd

struct FlixShip: FlixGFX, FlixInput {
  private let model: Model = Raylib.loadModel("Resources/ship.gltf")
  public var position: Vector3 {
    get {
      rigidbody.position.vector3
    }
    set {
      rigidbody.position = newValue.phyVector3
    }
  }
  public let scale: Float  // change rigidbody scale if you change this w/ getter setter
  public var color: Color = .darkGray
  public var rotation: PHYQuaternion {
    get {
      rigidbody.orientation
    }
    set {
      rigidbody.orientation = newValue
    }
  }
  public var constrainPlane: Bool = false
  public var wireframe: Bool = false
  public var wireframeColor: Color = .white
  public var lockRotationToZOnly: Bool = true

  public let rigidbody: PHYRigidBody
  public var forward: Vector3 {
    Vector3(x: 0, y: 1, z: 0).rotate(by: rotation.quaternion)
  }

  public init(pos: Vector3, scale: Float, color: Color, isStatic: Bool) {
    self.scale = scale
    self.color = color
    self.rigidbody = PHYRigidBodyFromRaylibModel(model: model, scale: scale, isStatic: false, collisionType: .concave)
    rigidbody.restitution = 0.3
    rigidbody.friction = 0.1
    rigidbody.linearDamping = 0.0
    rigidbody.angularDamping = 0.0
    rigidbody.position = pos.phyVector3
    rigidbody.isSleepingEnabled = false
    insertIntoDrawList()
    insertIntoInputList()
  }

  public func handleDraw() {
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

  func handleInput() {
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
  }
}
