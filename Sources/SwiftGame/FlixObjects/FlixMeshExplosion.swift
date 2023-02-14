import PhyKit
import Raylib
import RaylibC
import simd

// takes existing Model or Mesh, explodes the triangles, removes from collsion, and fades out, then removes from draw/phys lists
public class FlixMeshExplosion: FlixObject {
  private let timeToFade: Float = 5.0  //1.5
  private var fadeTimer: Float = 0.0
  private var triangleList: [FlixTriangle] = []

  init(mesh: Mesh, startingBody: PHYRigidBody, color: Color, collidingBody: PHYRigidBody? = nil) {
    super.init()
    fadeTimer = timeToFade
    self.color = color
    self.rigidbody?.isCollisionEnabled = false

    // let mesh: Mesh = model.meshes[0]

    // boringCubes(model: model, startingVel: startingVel, centerPos: centerPos, color: color)
    for i: Int in 0..<Int(mesh.triangleCount) {
      let flixTri: FlixTriangle = FlixTriangle(
        triangle: mesh.TriangleAtIndiceIndex(i), startingBody: startingBody, color: color, collidingBody: collidingBody)
      triangleList.append(flixTri)
    }
    flixType = FlixObjectType.explosionManager
    insertIntoDrawList()
  }

  override public func handleDraw() {
    fadeTimer -= FlixGame.deltaTime
    if fadeTimer <= 0 {
      removeFromDrawList()
      for tri in triangleList {
        tri.removeFromDrawList()
      }
      return
    } else {
      let fade: Float = fadeTimer / timeToFade
      for tri in triangleList {
        tri.color = Color(r: color.r, g: color.g, b: color.b, a: UInt8(Float(color.a) * fade))
      }
    }
  }

  // func boringCubes(model: Model, startingVel: Vector3, centerPos: Vector3, color: Color) {
  //   let mesh: Mesh = model.meshes[0]
  //   for i: Int in 0..<Int(mesh.vertexCount) {
  //     let newVert: Vector3 = Vector3(
  //       x: mesh.vertices[mesh.indexAt(i * 3)],
  //       y: mesh.vertices[mesh.indexAt(i * 3 + 1)],
  //       z: mesh.vertices[mesh.indexAt(i * 3 + 2)])
  //     // vertices.append(newVert)

  //     let newBox: FlixBox = FlixBox(
  //       pos: newVert,
  //       size: Vector3(0.1),
  //       color: color,
  //       isStatic: false, flixType: .explosion, autoInsertIntoList: false)

  //     newBox.rigidbody = PHYRigidBody(type: .dynamic(mass: 0.01), shape: PHYCollisionShapeBox(size: 0.1))
  //     newBox.rigidbody.restitution = 0.01
  //     newBox.rigidbody.friction = 0.01
  //     newBox.rigidbody.linearDamping = 0.1
  //     newBox.rigidbody.angularDamping = 0.1
  //     newBox.rigidbody.isSleepingEnabled = false
  //     newBox.rigidbody.linearVelocity = startingVel.phyVector3
  //     newBox.rigidbody.position = centerPos.phyVector3  //+ newVert.phyVector3
  //     newBox.insertIntoDrawList()
  //     // newBox.flixType = .explosion
  //     squareList.append(newBox)
  //   }
  // }
}
