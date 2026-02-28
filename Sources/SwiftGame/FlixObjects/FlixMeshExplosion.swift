import PhyKit
import Raylib
import RaylibC
import simd

public class FlixMeshExplosion: FlixObject {
    private let timeToFade: Float = 2.5
    private var fadeTimer: Float = 0.0
    private var triangleList: [FlixTriangle] = []

    init(triangles: [Triangle], startingBody: PHYRigidBody, color: Color, collidingBody: PHYRigidBody? = nil) {
        super.init(rigidbody: FlixObject.dummyRigidbody)
        self.usesPhysicsWorld = false
        self.isStaticInstanced = true
        fadeTimer = timeToFade
        self.color = color

        triangleList.reserveCapacity(triangles.count)
        for tri in triangles {
            let flixTri = FlixTriangle(
                triangle: tri, startingBody: startingBody, color: color, collidingBody: collidingBody)
            triangleList.append(flixTri)
        }
        flixType = FlixObjectType.explosionManager
        insertIntoDrawList()
    }

    override public func update(dt: Float) {
        if isDying { return }
        fadeTimer -= dt
        if fadeTimer <= 0 {
            die()
            for tri in triangleList { tri.die() }
        } else {
            let alpha = UInt8(Float(color.a) * (fadeTimer / timeToFade))
            let fadedColor = Color(r: color.r, g: color.g, b: color.b, a: alpha)
            for tri in triangleList { tri.color = fadedColor }
        }
    }

    override public func handleDraw() {}
}
