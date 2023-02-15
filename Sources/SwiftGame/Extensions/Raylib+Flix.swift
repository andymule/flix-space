import Raylib

extension ConfigFlags {
  // enable bitwise or
  public static func | (lhs: ConfigFlags, rhs: ConfigFlags) -> ConfigFlags {
    ConfigFlags(rawValue: lhs.rawValue | rhs.rawValue)
  }
}

extension Mesh {
  public func Vec3AtIndex(_ pos: Int) -> Vector3 {
    Vector3(
      x: self.vertices[pos * 3],
      y: self.vertices[pos * 3 + 1],
      z: self.vertices[pos * 3 + 2]
    )
  }

  public func Vec3AtIndex(_ pos: UInt16) -> Vector3 {
    Vec3AtIndex(Int(pos))
  }

  public func TriangleAtIndiceIndex(_ pos: Int) -> Triangle {
    Triangle(
      self.Vec3AtIndex(self.indices[pos * 3]),
      self.Vec3AtIndex(self.indices[pos * 3 + 1]),
      self.Vec3AtIndex(self.indices[pos * 3 + 2])
    )
  }
}

extension Raylib {
  public static func GenMeshFromTriangleArray(_ triangles: [Triangle]) -> Mesh {
    var mesh: Mesh = Mesh()
    mesh.triangleCount = Int32(triangles.count * 2)  // i draw faces both ways blindly
    mesh.vertexCount = Int32(triangles.count * 3)
    mesh.vertices = UnsafeMutablePointer<Float>.allocate(capacity: mesh.vertexCount.int * 3)
    mesh.texcoords = UnsafeMutablePointer<Float>.allocate(capacity: mesh.vertexCount.int * 2)
    mesh.normals = UnsafeMutablePointer<Float>.allocate(capacity: mesh.vertexCount.int * 3)
    mesh.tangents = UnsafeMutablePointer<Float>.allocate(capacity: mesh.vertexCount.int * 4)
    mesh.indices = UnsafeMutablePointer<UInt16>.allocate(capacity: mesh.triangleCount.int * 3)
    // mesh.colors = UnsafeMutablePointer<Color>.allocate(capacity: mesh.vertexCount.int)
    for t: Int in 0..<triangles.count {
      let triangle: Triangle = triangles[t]
      mesh.vertices[t * 9] = triangle.a.x
      mesh.vertices[t * 9 + 1] = triangle.a.y
      mesh.vertices[t * 9 + 2] = triangle.a.z
      mesh.vertices[t * 9 + 3] = triangle.b.x
      mesh.vertices[t * 9 + 4] = triangle.b.y
      mesh.vertices[t * 9 + 5] = triangle.b.z
      mesh.vertices[t * 9 + 6] = triangle.c.x
      mesh.vertices[t * 9 + 7] = triangle.c.y
      mesh.vertices[t * 9 + 8] = triangle.c.z
      // inefficiently draw triangles both clockwise and counterclockwise to escape culling
      mesh.indices[t * 6] = UInt16(t * 3)
      mesh.indices[t * 6 + 1] = UInt16(t * 3 + 1)
      mesh.indices[t * 6 + 2] = UInt16(t * 3 + 2)
      mesh.indices[t * 6 + 3] = UInt16(t * 3 + 2)
      mesh.indices[t * 6 + 4] = UInt16(t * 3 + 1)
      mesh.indices[t * 6 + 5] = UInt16(t * 3)
      // print(triangle)
    }

    Raylib.uploadMesh(&mesh, true)  // manage VRAM better?
    return mesh
  }
}

// not working yet
// func RaylibGenTrianglesFromModel(model: Model, scale: Float) -> [Triangle] {
//   let tempMesh: Mesh = model.meshes[0]
//   let tVerts: UnsafeMutablePointer<Float>? = tempMesh.vertices
//   //   var verticesConverted: [SCNVector3] = []
//   //   for v: Int in Int(0)..<Int(tempMesh.vertexCount) {
//   //     let x: Float = tVerts![v * 3] * scale
//   //     let y: Float = tVerts![v * 3 + 1] * scale
//   //     let z: Float = tVerts![v * 3 + 2] * scale
//   //     verticesConverted.append(SCNVector3(x, y, z))
//   //   }
//   //   let positionSource: SCNGeometrySource = SCNGeometrySource(vertices: verticesConverted)
//   var triangles: [Triangle] = .init()
//   for i: Int in Int(0)..<Int(tempMesh.triangleCount) {
//     let newTri = Triangle(

//     )
//     triangles.append(newTri)
//   }
//   //   let element: SCNGeometryElement = SCNGeometryElement(indices: indices, primitiveType: .triangles)
//   //   let geometry: SCNGeometry = SCNGeometry(sources: [positionSource], elements: [element])
//   //   return geometry
//   return triangles
// }

// Triangle Struct
public struct Triangle {
  var a: Vector3
  var b: Vector3
  var c: Vector3
  //   var color: Color
  public init(_ p1: Vector3, _ p2: Vector3, _ p3: Vector3) {
    a = p1
    b = p2
    c = p3
  }

  public func averagePos() -> Vector3 {
    (a + b + c) / 3.0
  }

  // pretty print
  public var description: String {
    return "Triangle: \(a), \(b), \(c)"
  }
}
