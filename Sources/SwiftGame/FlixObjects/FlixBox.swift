import PhyKit
import Raylib
import RaylibC
import simd

public class FlixBox: FlixObject {
  public static let staticModel: Model = Raylib.loadModelFromMesh(Raylib.genMeshCube(1, 1, 1))
  public var size: Vector3 = .zero
  var isExploding: Bool = false

  // TODO restore size, use staticmodel?
  public init(
    pos: Vector3, size: Vector3, color: Color, isStatic: Bool, flixType: FlixObjectType = .asteroid,
    autoInsertIntoList: Bool = true, useStaticModel: Bool = false
  ) {
    self.size = size
    // self.size = .one
    super.init()
    self.isStaticInstanced = useStaticModel
    if isStaticInstanced {
      // self.model = FlixBox.staticModel
    } else {
      self.model = Raylib.loadModelFromMesh(Raylib.genMeshCube(self.size.x, self.size.y, self.size.z))
      // let mesh: Mesh = model!.meshes[0]
      // print("veritces, triangles", mesh.vertexCount, mesh.triangleCount)
      // for i in 0..<model!.meshes[0].triangleCount.int {
      //   // print all indices
      //   print(i, mesh.indices[i * 3])
      //   print(i, mesh.indices[i * 3 + 1])
      //   print(i, mesh.indices[i * 3 + 2])
      //   print(i, mesh.Vec3AtIndex(mesh.indices[i * 3]))
      //   print(i, mesh.Vec3AtIndex(mesh.indices[i * 3+1]))
      //   print(i, mesh.Vec3AtIndex(mesh.indices[i * 3+2]))
      // }
    }

    
    // for v: Int32 in 0..<model!.meshes[0].vertexCount {
    //   let thisPoint = model!.meshes[0].vertices[Int(v)]
    //   if flixType == .asteroid && !abs(thisPoint).isNearlyEqual(to: self.size.x / 2.0)  {
    //     print("v: \(v) \(thisPoint) != \(self.size.x / 2.0)")
    //     fatalError()
    //   }
    // }

    // model = Raylib.loadModelFromMesh(Raylib.genMeshCube(self.size.x, self.size.y, self.size.z))
    self.color = color
    let collisionShape: PHYCollisionShapeBox = PHYCollisionShapeBox(width: self.size.x, height: self.size.y, length: self.size.z)
    let mass: Float = self.size.x + self.size.y + self.size.z
    self.rigidbody = PHYRigidBody(type: isStatic ? .static : .dynamic(mass: mass), shape: collisionShape)
    rigidbody!.restitution = 1.0
    rigidbody!.friction = 0.1
    rigidbody!.linearDamping = 0.0
    rigidbody!.angularDamping = 0.0
    rigidbody!.position = pos.phyVector3
    rigidbody!.isSleepingEnabled = false
    self.flixType = flixType
    if autoInsertIntoList {
      insertIntoDrawList()
    }
  }

  override public func handleDraw() {
    if isDying {
      return
    }
    if constrainPlane {
      rigidbody!.position.z = 0
    }
    let pos: Vector3 = rigidbody!.position.vector3
    var (axis, angle) = rigidbody!.orientation.vector4.toAxisAngle()
    angle = angle * 180 / Float.pi

    if isStaticInstanced {
      Raylib.drawModelEx(FlixBox.staticModel, pos, axis, angle, size, color)
      if wireframe {
        Raylib.drawModelWiresEx(FlixBox.staticModel, pos, axis, angle, size, wireframeColor)
      }
    } else {
      Raylib.drawModelEx(model!, pos, axis, angle, .one, color)
      if wireframe {
        Raylib.drawModelWiresEx(model!, pos, axis, angle, .one, wireframeColor)
      }
    }
  }



  override public func explode(_ callbackData: CallBackData? = nil) {
    if flixType == .asteroid && !isExploding {
      isExploding = true
      // FlixGame.score += 1
      for x in 0..<model!.meshes[0].vertexCount {
        print(x, model!.meshes[0].vertices[Int(x)])
        print(x, model!.meshes[0].vertices[Int(x+1)])
        print(x, model!.meshes[0].vertices[Int(x+2)])
      }
      _ = FlixMeshExplosion(model: model ?? FlixBox.staticModel, startingBody: rigidbody!, color: color, collidingBody: callbackData?.asBox() )
    }
  }
}
