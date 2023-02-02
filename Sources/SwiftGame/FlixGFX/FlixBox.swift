import PhyKit
import Raylib
import RaylibC
import simd

public struct FlixBox {
  static let model: Model = Raylib.loadModel("Resources/cube.obj")
  var boundingBox: BoundingBox
  public var pos: Vector3 {
    get {
      rigidbody.position.vector3
    }
    set {
      rigidbody.position = newValue.phyVector3
    }
  }
  public var size: Vector3 = Vector3(x: 1, y: 1, z: 1)
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
  public var wireframe: Bool = true
  public var wireframeColor: Color = .white
  //   var texture: Texture2D = Texture2D()
  //   var textureEnabled: Bool = false
  //   var textureRec: Rectangle = Rectangle(x: 0, y: 0, width: 0, height: 0)
  //   var textureColor: Color = .white
  //   var textureColorEnabled: Bool = false
  //   var textureColorBlend: Float = 0.0
  //   var textureColorBlendEnabled: Bool = false

  public let collisionShape: PHYCollisionShapeBox
  public let rigidbody: PHYRigidBody

  public init(pos: Vector3, size: Vector3, color: Color, isStatic: Bool) {
    self.size = size
    self.color = color
    self.collisionShape = PHYCollisionShapeBox(width: size.x, height: size.y, length: size.z)
    self.rigidbody = PHYRigidBody(type: isStatic ? .static : .dynamic, shape: collisionShape)
    // self.model = 
    self.boundingBox = Raylib.getMeshBoundingBox(FlixBox.model.meshes[0])
    rigidbody.restitution = 1.0
    rigidbody.friction = 0.1
    rigidbody.linearDamping = 0.1
    rigidbody.angularDamping = 0.1
    rigidbody.position = pos.phyVector3
    rigidbody.isSleepingEnabled = false
  }

  public func draw() {
    let pos: Vector3 = rigidbody.position.vector3

    // convert quaternion to axis angles
    let outAxis: UnsafeMutablePointer<Vector3> = UnsafeMutablePointer<Vector3>.allocate(capacity: 1)
    let outAngle: UnsafeMutablePointer<Float> = UnsafeMutablePointer<Float>.allocate(capacity: 1)
    RaylibC.QuaternionToAxisAngle(rotation.vector4, outAxis, outAngle)
    // convert outangle from radians to degrees
    outAngle.pointee = outAngle.pointee * 180 / Float.pi
    Raylib.drawModelEx(
      FlixBox.model, pos, outAxis.pointee, outAngle.pointee, RaylibC.Vector3Scale(size, 0.5), color)
    if wireframe {
      Raylib.drawModelWiresEx(
        FlixBox.model, pos, outAxis.pointee, outAngle.pointee, RaylibC.Vector3Scale(size, 0.5),
        wireframeColor)
    }
    if constrainPlane {
      rigidbody.position.z = 0
    }
  }
}
