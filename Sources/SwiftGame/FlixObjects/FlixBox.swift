import PhyKit
import Raylib
import RaylibC
import simd

public class FlixBox: FlixObject {
    public static let staticModel: Model = Raylib.loadModelFromMesh(Raylib.genMeshCube(1, 1, 1))
    public var size: Vector3 = .zero
    var isExploding: Bool = false

    public init(
        pos: Vector3, size: Vector3, color: Color, isStatic: Bool, flixType: FlixObjectType = .asteroid,
        autoInsertIntoList: Bool = true, useStaticModel: Bool = false
    ) {
        self.size = size
        super.init()
        self.isStaticInstanced = useStaticModel
        if !isStaticInstanced {
            self.model = Raylib.loadModelFromMesh(Raylib.genMeshCube(self.size.x, self.size.y, self.size.z))
        }
        self.color = color
        let collisionShape: PHYCollisionShapeBox = PHYCollisionShapeBox(
            width: self.size.x, height: self.size.y, length: self.size.z)
        let mass: Float = self.size.x + self.size.y + self.size.z
        self.rigidbody = PHYRigidBody(type: isStatic ? .static : .dynamic(mass: mass), shape: collisionShape)
        rigidbody!.restitution = 0.75
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

    override public func explode(_ callbackData: FlixCallBackData? = nil) {
        if flixType == .asteroid && !isExploding {
            isExploding = true
            if isStaticInstanced {
                // generate a temp instance for explosion and allows for proper mem free on it later with FlixObject destructors
                self.model = Raylib.loadModelFromMesh(Raylib.genMeshCube(self.size.x, self.size.y, self.size.z))
            }
            _ = FlixMeshExplosion(
                mesh: model!.meshes[0], startingBody: rigidbody!,
                color: color, collidingBody: callbackData?.cb_rigidbodies[0])
        }
    }
}
