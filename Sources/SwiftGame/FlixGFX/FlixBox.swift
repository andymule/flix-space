import PhyKit
import Raylib
import RaylibC
import simd
// import SceneKit
// import SceneKit.ModelIO

public struct FlixBox : FlixGFX {
  public static let model: Model = Raylib.loadModelFromMesh(Raylib.genMeshCube(1, 1, 1)) //Raylib.loadModel("Resources/cube.obj")
  public var boundingBox: BoundingBox
  public var position: Vector3 {
    get {
      rigidbody.position.vector3
    }
    set {
      rigidbody.position = newValue.phyVector3
    }
  }
  public var size: Vector3 //= Vector3(x: 1, y: 1, z: 1)
  public var color: Color //= .darkGray
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

  public let collisionShape: PHYCollisionShape
  public let rigidbody: PHYRigidBody
  public var forward: Vector3 {
    get {
      Vector3(x: 0, y: 0, z: 1).rotate(by: rotation.quaternion)
    }
  }
  public init(pos: Vector3, size: Vector3, color: Color, isStatic: Bool) {
    self.size = size
    self.color = color
    self.collisionShape = PHYCollisionShapeBox(width: size.x, height: size.y, length: size.z)
    // var customCollider: PHYCollisionShapeGeometry = PHYCollisionShapeGeometry(geometry: customGeometry, type: .concave)
    self.rigidbody = PHYRigidBody(type: isStatic ? .static : .dynamic, shape: collisionShape)
    self.boundingBox = Raylib.getMeshBoundingBox(FlixBox.model.meshes[0])
    rigidbody.restitution = 1.0
    rigidbody.friction = 0.1
    rigidbody.linearDamping = 0.0
    rigidbody.angularDamping = 0.0
    rigidbody.position = pos.phyVector3
    rigidbody.isSleepingEnabled = false
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