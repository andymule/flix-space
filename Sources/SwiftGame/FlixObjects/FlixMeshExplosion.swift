import PhyKit
import Raylib
import RaylibC
import simd

// takes existing Model or Mesh, explodes the triangles, removes from collsion, and fades out, then removes from draw/phys lists
public class FlixMeshExplosion: FlixObject {
  private let timeToFade: Float = 1.5
  private var fadeTimer: Float = 0.0
  //   private var triangleList: [Triangle] = []
  // private var triangleColliderList: [PHYCollisionShapeGeometry] = []
  private var squareList: [FlixBox] = []
  private var squareColliderList: [PHYCollisionShapeBox] = []

  init(model: Model, startingVel: Vector3, centerPos: Vector3, color: Color) {
    super.init()
    fadeTimer = timeToFade
    self.color = color
    self.rigidbody.isCollisionEnabled = false

    var vertices: [Vector3] = [Vector3]()
    let mesh: Mesh = model.meshes[0]
    // print(Int(mesh.vertexCount))
    for i: Int in 0..<Int(mesh.vertexCount) {
      let newVert: Vector3 = Vector3(
        x: mesh.vertices[mesh.indexAt(i * 3)],
        y: mesh.vertices[mesh.indexAt(i * 3 + 1)],
        z: mesh.vertices[mesh.indexAt(i * 3 + 2)])
      vertices.append(newVert)

      let newBox: FlixBox = FlixBox(
        pos: newVert,
        size: Vector3(0.1),
        color: color,
        isStatic: false, flixType: .explosion, autoInsertIntoList: false)

      newBox.rigidbody = PHYRigidBody(type: .dynamic(mass: 0.01), shape: PHYCollisionShapeBox(size: 0.1))
      newBox.rigidbody.restitution = 0.01
      newBox.rigidbody.friction = 0.01
      newBox.rigidbody.linearDamping = 0.1
      newBox.rigidbody.angularDamping = 0.1
      newBox.rigidbody.isSleepingEnabled = false
      newBox.rigidbody.linearVelocity = startingVel.phyVector3
      newBox.rigidbody.position = centerPos.phyVector3  //+ newVert.phyVector3
      newBox.insertIntoDrawList()
      // newBox.flixType = .explosion
      squareList.append(newBox)
    }
    // print(squareList.count)
    flixType = .explosionManager
    insertIntoDrawList()
  }

  override public func handleDraw() {
    fadeTimer -= FlixGame.deltaTime
    if fadeTimer <= 0 {
      removeFromDrawList()
      for box: FlixBox in squareList {
        box.removeFromDrawList()
      }
      return
    } else {
      let fade: Float = fadeTimer / timeToFade
      for box: FlixBox in squareList {
        box.color = Color(r: color.r, g: color.g, b: color.b, a: UInt8(Float(color.a) * fade))
      }
    }
  }
}

func RaylibGenTrianglesFromModel(model: Model, scale: Float) -> [Triangle] {
  let tempMesh: Mesh = model.meshes[0]
  let tVerts: UnsafeMutablePointer<Float>? = tempMesh.vertices
  //   var verticesConverted: [SCNVector3] = []
  //   for v: Int in Int(0)..<Int(tempMesh.vertexCount) {
  //     let x: Float = tVerts![v * 3] * scale
  //     let y: Float = tVerts![v * 3 + 1] * scale
  //     let z: Float = tVerts![v * 3 + 2] * scale
  //     verticesConverted.append(SCNVector3(x, y, z))
  //   }
  //   let positionSource: SCNGeometrySource = SCNGeometrySource(vertices: verticesConverted)
  var triangles: [Triangle] = .init()
  for i: Int in Int(0)..<Int(tempMesh.triangleCount) {
    let newTri = Triangle(
      p1: Vector3(
        x: tVerts![tempMesh.indexAt(i * 3)], y: tVerts![tempMesh.indexAt(i * 3 + 1)], z: tVerts![tempMesh.indexAt(i * 3 + 2)]),
      p2: Vector3(
        x: tVerts![tempMesh.indexAt(i * 3 + 3)], y: tVerts![tempMesh.indexAt(i * 3 + 4)], z: tVerts![tempMesh.indexAt(i * 3 + 5)]),
      p3: Vector3(
        x: tVerts![tempMesh.indexAt(i * 3 + 6)], y: tVerts![tempMesh.indexAt(i * 3 + 7)], z: tVerts![tempMesh.indexAt(i * 3 + 8)])
    )
    triangles.append(newTri)
  }
  //   let element: SCNGeometryElement = SCNGeometryElement(indices: indices, primitiveType: .triangles)
  //   let geometry: SCNGeometry = SCNGeometry(sources: [positionSource], elements: [element])
  //   return geometry
  return triangles
}

// Triangle Struct
public struct Triangle {
  var p1: Vector3
  var p2: Vector3
  var p3: Vector3
  //   var color: Color
}
