import PhyKit
import Raylib
import RaylibC
import simd

// takes existing Model or Mesh, explodes the triangles, removes from collsion, and fades out, then removes from draw/phys lists
public class FlixMeshExplosion: FlixObject {
    private var timeToLive: Float = 5.0
    private var triangleList: [Triangle] = []

    init (model: Model, color: Color) {
        super.init()
        self.color = color
        // self.triangleList = model.meshes[0].
        self.rigidbody = PHYRigidBody(type: .static, shape: PHYCollisionShapeBox(width: 0, height: 0, length: 0))
        rigidbody.isSleepingEnabled = false
        rigidbody.position = Vector3.zero.phyVector3
        insertIntoDrawList()
    }
}

// Triangle Struct
public struct Triangle {
    var p1: Vector3
    var p2: Vector3
    var p3: Vector3
    var color: Color
}

