import PhyKit
import Raylib
import RaylibC
import simd

public class FlixBullet: FlixObject, Explodable {

    private var timeToLive: Float = 20.0
    let owner: FlixCanShoot
    var isExploding: Bool = false

    public static let sharedModel: Model = Raylib.loadModelFromMesh(Raylib.genMeshCube(1, 1, 1))
    public var scale: Float

    public init(pos: Vector3, scale: Float, color: Color, owner: FlixCanShoot, angularVel: PHYVector3 = PHYVector3(0, 0, 0)) {
        self.scale = scale
        self.owner = owner
        let collisionShape = PHYCollisionShapeBox(width: scale, height: scale, length: scale)
        let rb = PHYRigidBody(type: .dynamic(mass: 10.0), shape: collisionShape)
        rb.angularVelocity = angularVel
        rb.restitution = 0.0
        rb.friction = 1.0
        rb.linearDamping = 0.0
        rb.angularDamping = 0.0
        rb.position = pos.phyVector3
        rb.isSleepingEnabled = false
        super.init(rigidbody: rb)
        self.color = color
        flixType = .bullet
        insertIntoDrawList()
    }

    override public func update(dt: Float) {
        if isDying { return }
        timeToLive -= dt
        if timeToLive <= 0 {
            owner.bulletDeathCallback(addPoints: false)
            die()
            return
        }
        if constrainPlane {
            rigidbody.position.z = 0
        }
    }

    override public func handleDraw() {
        if isDying { return }
        let pos: Vector3 = rigidbody.position.vector3
        var (axis, angle) = rigidbody.orientation.vector4.toAxisAngle()
        angle = angle * 180 / Float.pi
        Raylib.drawModelEx(FlixBullet.sharedModel, pos, axis, angle, Vector3(scale), color)
        if wireframe {
            Raylib.drawModelWiresEx(FlixBullet.sharedModel, pos, axis, angle, Vector3(scale), wireframeColor)
        }
    }

    public func explode(_ data: FlixCollisionData? = nil) {
        guard !isExploding else { return }
        isExploding = true
        owner.bulletDeathCallback(addPoints: false)
    }
}
