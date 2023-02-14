import PhyKit
import Raylib
import RaylibC
import simd

public class FlixTriangle: FlixObject {
  public var scale: Float = 1

  public init(triangle: Triangle, startingBody: PHYRigidBody, color: Color, collidingBody: PHYRigidBody? = nil) {
    super.init()
    self.model = Raylib.loadModelFromMesh(Raylib.GenMeshFromTriangleArray([triangle]))
    self.color = color
    self.rigidbody = PHYRigidBodyFromRaylibModel(
      model: model!, scale: scale, isStatic: false, mass: 0.01, collisionType: .concave)
    rigidbody!.restitution = 0.0
    rigidbody!.friction = 0.1
    rigidbody!.linearDamping = 0.3
    rigidbody!.angularDamping = 0.3
    rigidbody!.position = startingBody.position  //+ triangle.averagePos().scale(0.3).phyVector3
    rigidbody!.linearVelocity =
      startingBody.linearVelocity.vector3.scale(0.5).phyVector3
      + (collidingBody?.linearVelocity.vector3.scale(.random(in: 0.2...0.5)).phyVector3 ?? PHYVector3(0, 0, 0))
    rigidbody!.angularVelocity = startingBody.angularVelocity.vector3.scale(.random(in: -1.0...1.0)).phyVector3
    rigidbody!.isSleepingEnabled = false
    self.flixType = .triangle
    // wireframe = true
    // wireframeColor = .black
    insertIntoDrawList()
  }

  override public func handleDraw() {
    if constrainPlane {
      rigidbody!.position.z = 0
    }
    let pos: Vector3 = rigidbody!.position.vector3
    var (axis, angle) = rigidbody!.orientation.vector4.toAxisAngle()
    angle = angle.rad2deg
    Raylib.drawModelEx(model!, pos, axis, angle, Vector3(scale), color)
    if wireframe {
      Raylib.drawModelWiresEx(model!, pos, axis, angle, Vector3(scale), wireframeColor)
    }
  }
}
