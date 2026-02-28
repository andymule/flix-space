import PhyKit
import Raylib
import RaylibC
import simd

public class FlixBox: FlixObject, Explodable {
    public static let staticModel: Model = Raylib.loadModelFromMesh(Raylib.genMeshCube(1, 1, 1))
    public var size: Vector3 = .zero
    var isExploding: Bool = false

    public init(
        pos: Vector3, size: Vector3, color: Color, isStatic: Bool, flixType: FlixObjectType = .asteroid,
        autoInsertIntoList: Bool = true, useStaticModel: Bool = false
    ) {
        self.size = size
        let collisionShape = PHYCollisionShapeBox(
            width: size.x, height: size.y, length: size.z)
        let density: Float = 5.0
        let mass: Float = size.x * size.y * size.z * density
        let rb = PHYRigidBody(type: isStatic ? .static : .dynamic(mass: mass), shape: collisionShape)
        rb.restitution = 0.75
        rb.friction = 0.1
        rb.linearDamping = 0.0
        rb.angularDamping = 0.0
        rb.position = pos.phyVector3
        rb.isSleepingEnabled = !isStatic
        super.init(rigidbody: rb)
        self.isStaticInstanced = useStaticModel
        if !isStaticInstanced {
            self.model = Raylib.loadModelFromMesh(Raylib.genMeshCube(size.x, size.y, size.z))
        }
        self.color = color
        self.flixType = flixType
        if autoInsertIntoList {
            insertIntoDrawList()
        }
    }

    override public func update(dt: Float) {
        if isDying { return }
        if constrainPlane {
            rigidbody.position.z = 0
        }
    }

    override public func handleDraw() {
        if isDying { return }
        let pos: Vector3 = rigidbody.position.vector3
        var (axis, angle) = rigidbody.orientation.vector4.toAxisAngle()
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

    /// Generates 12 triangles for a cube with given dimensions, purely on CPU (no GPU mesh upload).
    static func cubeTriangles(size: Vector3) -> [Triangle] {
        let hx = size.x / 2, hy = size.y / 2, hz = size.z / 2
        let v0 = Vector3(-hx, -hy,  hz), v1 = Vector3( hx, -hy,  hz)
        let v2 = Vector3( hx,  hy,  hz), v3 = Vector3(-hx,  hy,  hz)
        let v4 = Vector3(-hx, -hy, -hz), v5 = Vector3( hx, -hy, -hz)
        let v6 = Vector3( hx,  hy, -hz), v7 = Vector3(-hx,  hy, -hz)
        return [
            Triangle(v0, v1, v2), Triangle(v0, v2, v3),
            Triangle(v5, v4, v7), Triangle(v5, v7, v6),
            Triangle(v1, v5, v6), Triangle(v1, v6, v2),
            Triangle(v4, v0, v3), Triangle(v4, v3, v7),
            Triangle(v3, v2, v6), Triangle(v3, v6, v7),
            Triangle(v4, v5, v1), Triangle(v4, v1, v0),
        ]
    }

    public func explode(_ data: FlixCollisionData? = nil) {
        guard flixType == .asteroid, !isExploding else { return }
        isExploding = true
        var collidingBody: PHYRigidBody? = nil
        if case .impactFrom(let body) = data {
            collidingBody = body
        }
        _ = FlixMeshExplosion(
            triangles: FlixBox.cubeTriangles(size: size),
            startingBody: rigidbody,
            color: color,
            collidingBody: collidingBody)
    }
}
