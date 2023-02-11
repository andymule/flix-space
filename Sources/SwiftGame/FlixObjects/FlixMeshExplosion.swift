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
