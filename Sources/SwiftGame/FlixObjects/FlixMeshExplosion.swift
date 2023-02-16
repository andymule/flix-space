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
            die()
            triangleList.forEach({ $0.die() })
            return
        } else {
            triangleList.forEach({
                $0.color = Color(r: color.r, g: color.g, b: color.b, a: UInt8(Float(color.a) * (fadeTimer / timeToFade)))
            })
        }
    }
}
