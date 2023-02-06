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
  public let scale: Float // change rigidbody scale if you change this w/ getter setter
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

  // public var collisionShape: PHYCollisionShape
  public let rigidbody: PHYRigidBody
  public var forward: Vector3 {
    Vector3(x: 0, y: 1, z: 0).rotate(by: rotation.quaternion)
  }

  public init(pos: Vector3, scale: Float, color: Color, isStatic: Bool) {
    // model = Raylib.loadModel("Resources/ship.gltf")
    self.scale = scale
    self.color = color
    self.rigidbody =  PHYRigidBodyFromRaylibModel(model: model, scale: scale, isStatic: false, collisionType: .concave)
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

  // Example creating SCNGeometry using vertex data
  struct Vertex {
    let x: Float
    let y: Float
    let z: Float
    let r: Float
    let g: Float
    let b: Float
  }

  // static let vertices: [Vertex] = [
  //   Vertex(x: 0.0, y: 0.0, z: 0.0, r: 1.0, g: 0.0, b: 0.0),
  //   Vertex(x: 1.0, y: 0.0, z: 0.0, r: 0.0, g: 0.0, b: 1.0),
  //   Vertex(x: 1.0, y: 0.0, z: -0.5, r: 0.0, g: 0.0, b: 1.0),
  //   Vertex(x: 0.0, y: 1.0, z: 0.0, r: 0.0, g: 0.0, b: 1.0),
  // ]

  // static func ShipMesh() ->  Mesh {
  //   let verticesConverted = vertices.map { Vector3(x: $0.x, y: $0.y, z: $0.z) }

  //   var mesh = Mesh()
  //     // mesh.triangleCount = 2;
  //     // mesh.vertexCount = 4
  //     // mesh.vertices = 
  //     // mesh.texcoords = (float *)MemAlloc(mesh.vertexCount*2*sizeof(float));   // 3 vertices, 2 coordinates each (x, y)
  //     // mesh.normals = (float *)MemAlloc(mesh.vertexCount*3*sizeof(float));     // 3 vertices, 3 coordinates each (x, y, z)

  //   return mesh
  // }

  
}

