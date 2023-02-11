import PhyKit
import Raylib
import RaylibC

// this file bridges two repositories together for easier use
// https://github.com/STREGAsGate/Raylib
// https://github.com/AdamEisfeld/PhyKit

// example use:
// let rigidbody : PHYRigidBody =  PHYRigidBodyFromRaylibModel(model: Raylib.loadModel("Resources/ship.gltf"), scale: 0.5, isStatic: false, mass: 2.2, collisionType: .concave)

func RaylibGenSCNGeometryFromModel(model: Model, scale: Float) -> SCNGeometry {
  let tempMesh: Mesh = model.meshes[0]
  let tVerts: UnsafeMutablePointer<Float>? = tempMesh.vertices
  var verticesConverted: [SCNVector3] = []
  for v: Int in Int(0)..<Int(tempMesh.vertexCount) {
    let x: Float = tVerts![v * 3] * scale
    let y: Float = tVerts![v * 3 + 1] * scale
    let z: Float = tVerts![v * 3 + 2] * scale
    verticesConverted.append(SCNVector3(x, y, z))
  }
  let positionSource: SCNGeometrySource = SCNGeometrySource(vertices: verticesConverted)
  var indices: [UInt16] = .init()
  for i: Int in Int(0)..<Int(tempMesh.triangleCount) {
    indices.append(UInt16(tempMesh.indices[i * 3]))
    indices.append(UInt16(tempMesh.indices[i * 3 + 1]))
    indices.append(UInt16(tempMesh.indices[i * 3 + 2]))
  }
  let element: SCNGeometryElement = SCNGeometryElement(indices: indices, primitiveType: .triangles)
  let geometry: SCNGeometry = SCNGeometry(sources: [positionSource], elements: [element])
  return geometry
}

func PHYRigidBodyFromRaylibModel(
  model: Model, scale: Float, isStatic: Bool, mass: Float, collisionType: PHYCollisionShapeGeometry.PHYCollisionShapeGeometryType
) -> PHYRigidBody {
  let phyGeo: PHYGeometry = PHYGeometry(scnGeometry: RaylibGenSCNGeometryFromModel(model: model, scale: scale))
  let collisionShape: PHYCollisionShapeGeometry = PHYCollisionShapeGeometry(geometry: phyGeo, type: collisionType)
  return PHYRigidBody(type: isStatic ? .static : .dynamic(mass: mass), shape: collisionShape)
}

extension PHYVector3 {
  public var vector3: Vector3 {
    Vector3(x: x, y: y, z: z)
  }
  public var vector2: Vector2 {
    Vector2(x: x, y: y)
  }
  public static func += (lhs: inout PHYVector3, rhs: PHYVector3) {
    lhs = PHYVector3(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
  }
  public static func + (lhs: PHYVector3, rhs: PHYVector3) -> PHYVector3 {
    PHYVector3(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
  }
}

extension Vector3 {
  public var phyVector3: PhyKit.PHYVector3 {
    PHYVector3(x: x, y: y, z: z)
  }
  init(_ uniform: Float) {
    self.init(x: uniform, y: uniform, z: uniform)
  }
  static func random(in range: ClosedRange<Float>) -> Vector3 {
    Vector3(
      x: Float.random(in: range),
      y: Float.random(in: range),
      z: Float.random(in: range)
    )
  }
}

extension Vector2 {
  public var phyVector3: PhyKit.PHYVector3 {
    PHYVector3(x: x, y: y, z: 0)
  }
}

extension PHYQuaternion {
  public var vector4: Vector4 {
    Vector4(x: x, y: y, z: z, w: w)
  }
  public var quaternion: Quaternion {
    Vector4(x: x, y: y, z: z, w: w)
  }
}

extension Quaternion {
  public var phyQuat: PHYQuaternion {
    PHYQuaternion(x: x, y: y, z: z, w: w)
  }
}
