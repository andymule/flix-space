import PhyKit
import Raylib
import RaylibC
import simd

public class FlixShip: FlixObject, FlixInput, FlixCanShoot {
    private let bulletsMAX = 9999
    private var bulletsActiveCount = 0
    private let recoilScale: Float = 0
    private let accel: Float = 3.0

    private let firingCooldown: Float = 0.01
    private var firingCooldownTimer: Float = 0.0
    public var isInfluencedCurrently: Bool = false

    var score = 0

    public let scale: Float

    private let boostModel: Model
    let boostTriangle: Triangle = Triangle(
        Vector3(x: -0.45, y: -0.65, z: 0),
        Vector3(x: 0.45, y: -0.65, z: 0),
        Vector3(x: 0, y: -1.5, z: 0)
    )
    private let brakeModel: Model
    let brakeTriangles: [Triangle] = [
        Triangle(
            Vector3(x: -0.5, y: 0.6, z: 0),
            Vector3(x: -0.9, y: -0.3, z: 0),
            Vector3(x: -0.2, y: -0.3, z: 0)
        ),
        Triangle(
            Vector3(x: 0.5, y: 0.6, z: 0),
            Vector3(x: 0.9, y: -0.3, z: 0),
            Vector3(x: 0.2, y: -0.3, z: 0)
        ),
    ]
    private var isBoosting = false
    private var isBraking = false
    public var lockRotationToZOnly: Bool = true

    public var forward: Vector3 {
        Vector3(x: 0, y: 1, z: 0).rotate(by: rotation.quaternion)
    }

    public init(pos: Vector3, scale: Float, color: Color, isStatic: Bool) {
        self.scale = scale
        boostModel = Raylib.loadModelFromMesh(Raylib.GenMeshFromTriangleArray([boostTriangle]))
        brakeModel = Raylib.loadModelFromMesh(Raylib.GenMeshFromTriangleArray(brakeTriangles))
        let shipModel = Raylib.loadModel(Bundle.module.path(forResource: "ship", ofType: "gltf")!)
        let rb = PHYRigidBodyFromRaylibModel(
            model: shipModel, scale: scale, isStatic: false, mass: scale, collisionType: .concave)
        rb.restitution = 0.3
        rb.friction = 1.0
        rb.linearDamping = 0.0
        rb.angularDamping = 0.0
        rb.position = pos.phyVector3
        rb.isSleepingEnabled = false
        super.init(rigidbody: rb)
        self.model = shipModel
        self.color = color
        flixType = .ship
        insertIntoDrawList()
        insertIntoInputList()
    }

    override public func update(dt: Float) {
        if constrainPlane {
            rigidbody.position.z = 0
        }
        if lockRotationToZOnly {
            rigidbody.orientation = PHYQuaternion.euler(0, 0, rigidbody.orientation.vector4.toEuler().z, .radians)
            rigidbody.angularVelocity = PHYVector3(0, 0, rigidbody.angularVelocity.z)
        }
    }

    override public func handleDraw() {
        let pos: Vector3 = rigidbody.position.vector3
        let (axis, angle) = rigidbody.orientation.vector4.toAxisAngle()
        let angle2 = angle * 180 / Float.pi
        if isBraking {
            Raylib.drawModelEx(brakeModel, pos, axis, angle2, Vector3(scale), .orange)
        }
        Raylib.drawModelEx(model!, pos, axis, angle2, Vector3(x: scale * 0.8, y: scale, z: scale), color)
        if isBoosting {
            Raylib.drawModelEx(boostModel, pos, axis, angle2, Vector3(scale), .orange)
        }
        if wireframe {
            Raylib.drawModelWiresEx(model!, pos, axis, angle2, Vector3(scale), wireframeColor)
        }
    }

    public func handleInput() {
        isBoosting = false
        isBraking = false
        if Raylib.isKeyDown(.right) {
            rigidbody.angularVelocity += PHYVector3(x: 0, y: 0, z: -accel * FlixGame.deltaTime)
        }
        if Raylib.isKeyDown(.left) {
            rigidbody.angularVelocity += PHYVector3(x: 0, y: 0, z: accel * FlixGame.deltaTime)
        }
        if Raylib.isKeyDown(.up) {
            isBoosting = true
            rigidbody.linearVelocity += forward.scale(accel * FlixGame.deltaTime).phyVector3
        }
        if Raylib.isKeyDown(.down) {
            isBraking = true
            rigidbody.linearVelocity += forward.scale(-accel * FlixGame.deltaTime).phyVector3
        }
        firingCooldownTimer -= FlixGame.deltaTime
        if Raylib.isKeyDown(.space) {
            fire()
        }
    }

    public func fire() {
        if bulletsActiveCount >= bulletsMAX || firingCooldownTimer > 0 {
            return
        }
        firingCooldownTimer = firingCooldown
        bulletsActiveCount += 1
        let bullet = FlixBullet(
            pos: position, scale: 0.1, color: .cyan, owner: self, angularVel: rigidbody.angularVelocity)
        bullet.rigidbody.linearVelocity =
            rigidbody.linearVelocity + forward.scale(6).phyVector3
        rigidbody.linearVelocity = rigidbody.linearVelocity + forward.scale(recoilScale).phyVector3
        bullet.rigidbody.position = position.phyVector3 + forward.scale(scale * 1.3).phyVector3
        bullet.rigidbody.orientation = rotation
    }

    public func bulletDeathCallback(addPoints: Bool = false) {
        if addPoints {
            score += 1
            print("score: \(score)")
        }
        bulletsActiveCount -= 1
    }
}
