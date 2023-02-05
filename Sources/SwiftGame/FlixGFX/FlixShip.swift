import PhyKit
import Raylib
import RaylibC
import SceneKit
import SceneKit.ModelIO
import simd

struct FlixShip: FlixGFX, FlixInput {
  public var model: Model = .init()  //= Raylib.loadModel("Resources/spaceship.obj")
  // var collisionShapes: [PHYCollisionShape] = []
  // public static var model: Model = .init()
  // public var boundingBox: BoundingBox
  public var position: Vector3 {
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

  public var collisionShape: PHYCollisionShape
  public let rigidbody: PHYRigidBody
  public var forward: Vector3 {
    Vector3(x: 0, y: 1, z: 0).rotate(by: rotation.quaternion)
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
    model = Raylib.loadModel("Resources/ship.gltf")
    // model = Raylib.loadModelFromMesh(FlixShip.ShipMesh())
    self.size = size
    self.color = color

    // make a scene node from a USDZ file

    // // load usdz into scnnode
    // let ass = MDLAsset(url: URL(fileURLWithPath: "Resources/ship.usdz"))
    // ass.loadTextures()
    // let shipnode = SCNNode(mdlObject: ass.object(at: 0))
    // let testGeo: PHYGeometry = PHYGeometry(scnGeometry: shipnode.childNodes[0].geometry!)
    // let phyGeo: PHYCollisionShapeGeometry = .init(geometry: testGeo, type: .concave)
    // let testData: Data = phyGeo.serialize()
    // collisionShape = PHYCollisionShapeFromData(serializedData: testData)
    // collisionShape = PHYCollisionShapeGeometry(geometry: PHYGeometry(model: ass.object(at: 0)), type: .concave)
    let phyGeo = PHYGeometry(scnGeometry: FlixShip.ShipGeometry(scale: size.x))
    collisionShape = PHYCollisionShapeGeometry(geometry: phyGeo, type: .concave)  //PHYCollisionShapeBox(size: size.x, transform: PHYMatrix4())
    self.rigidbody = PHYRigidBody(type: isStatic ? .static : .dynamic, shape: collisionShape)
    // self.boundingBox = Raylib.getMeshBoundingBox(model.meshes[0])
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
      rigidbody.orientation = PHYQuaternion.euler(0, 0, rigidbody.orientation.vector4.toEuler().z * 180 / Float.pi)
      rigidbody.angularVelocity = PHYVector3(0, 0, rigidbody.angularVelocity.z)
    }
    let pos: Vector3 = rigidbody.position.vector3
    var (axis, angle) = rigidbody.orientation.vector4.toAxisAngle()
    angle = angle * 180 / Float.pi
    Raylib.drawModelEx(model, pos, axis, angle, size, color)
    if wireframe {
      Raylib.drawModelWiresEx(model, pos, axis, angle, size, wireframeColor)
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

  static func ShipGeometry(scale: Float) -> SCNGeometry {
    let tempmodel = Raylib.loadModel("Resources/ship.gltf")
    let tempMesh = tempmodel.meshes[0]
    let tVerts: UnsafeMutablePointer<Float>? = tempMesh.vertices
    // convert pointer to array
    var verticesConverted: [SCNVector3] = []
    for v: Int in Int(0)..<Int(tempMesh.vertexCount) {
      let x: Float = tVerts![v*3] * scale
      let y: Float = tVerts![v*3+1] * scale
      let z: Float = tVerts![v*3+2] * scale
      verticesConverted.append(SCNVector3(x, y, z))
    }

    // let verticesConverted: [SCNVector3] = vertices.map { SCNVector3($0.x, $0.y, $0.z) }
    // let verticesConverted: [SCNVector3] = tempMesh.vertices.map { SCNVector3($0.x, $0.y, $0.z) }
    let positionSource = SCNGeometrySource(vertices: verticesConverted)
    // let indices: [UInt16] = [
      // 0, 1, 3,
      // 1, 2, 3,
      // 2, 0, 3,
      // 3, 0, 2,
      // 0, 2, 1,
    // ]
    var indices: [UInt16] = .init()
    for i: Int in Int(0)..<Int(tempMesh.triangleCount) {
      indices.append(UInt16(tempMesh.indices[i*3]))
      indices.append(UInt16(tempMesh.indices[i*3+1]))
      indices.append(UInt16(tempMesh.indices[i*3+2]))
    }
    let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
    let geometry = SCNGeometry(sources: [positionSource], elements: [element])
    return geometry
  }
}
