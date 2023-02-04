import PhyKit
import Raylib
import RaylibC
import simd

struct FlixShip: FlixGFX, FlixInput {
  public static let model: Model = Raylib.loadModel("Resources/spaceship2.obj")
  // public static var model: Model = .init()
  public var boundingBox: BoundingBox
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
  public var wireframe: Bool = false
  public var wireframeColor: Color = .white
  public var lockRotation: Bool = true

  public let collisionShape: PHYCollisionShapeBox
  public let rigidbody: PHYRigidBody
  public var forward: Vector3 {
    Vector3(x: 0, y: 0, z: 1).rotate(by: rotation.quaternion)
  }

  public init(pos: Vector3, size: Vector3, color: Color, isStatic: Bool) {
    // FlixShip.model = {
    //   var mesh: Mesh = Raylib.genMeshPoly(5, 1)
    //   for i in 0..<Int(mesh.vertexCount) {
    //     mesh.vertices[i+0] = .random(in: 0...1)
    //     mesh.vertices[i+1] = .random(in: 0...1)
    //     mesh.vertices[i+2] = .random(in: 0...1)
    //     // mesh.colors[i+0] = 1
    //     // mesh.colors[i+1] = 1
    //     // mesh.colors[i+2] = 1
    //     // mesh.colors[i+3] = 1
    //   }
    //   Raylib.genMeshBinormals(&mesh)
    //   // let model = Raylib.loadModel("Resources/spaceship.obj")
    //   let model = Raylib.loadModelFromMesh(mesh)
    //   // model.materials[0].maps[0].texture = Texture2D(id: 0, width: 1, height: 1, mipmaps: 1, format: 1) //Raylib.loadTexture("Resources/spaceship.png")
    //   return model
    // }()
    self.size = size
    self.color = color
    self.collisionShape = PHYCollisionShapeBox(width: size.x, height: size.y, length: size.z)
    self.rigidbody = PHYRigidBody(type: isStatic ? .static : .dynamic, shape: collisionShape)
    self.boundingBox = Raylib.getMeshBoundingBox(FlixShip.model.meshes[0])
    rigidbody.restitution = 0.3
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
    if lockRotation {
      // let justZRotation
      // rigidbody.orientation = PHYQuaternion.euler(0, 0, rigidbody.orientation.vector4.toEuler().z)
      rigidbody.angularVelocity = PHYVector3(0, 0, rigidbody.angularVelocity.z)
    }
    let pos: Vector3 = rigidbody.position.vector3
    var (axis, angle) = rigidbody.orientation.vector4.toAxisAngle()
    angle = angle * 180 / Float.pi
    Raylib.drawModelEx(FlixShip.model, pos, axis, angle, size, color)
    if wireframe {
      Raylib.drawModelWiresEx(FlixShip.model, pos, axis, angle, size, wireframeColor)
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
