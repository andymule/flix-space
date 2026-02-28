import PhyKit
import Raylib
import RaylibC
import simd

public class FlixObject: Equatable, Hashable {
    public var isStaticInstanced = false
    public var isDying = false
    public var usesPhysicsWorld = true

    public var model: Model? = nil
    public let rigidbody: PHYRigidBody

    /// Shared rigidbody for objects that don't participate in physics (triangles, explosion managers)
    static let dummyRigidbody: PHYRigidBody = {
        let shape = PHYCollisionShapeBox(size: 0.01)
        let rb = PHYRigidBody(type: .static, shape: shape)
        rb.isCollisionEnabled = false
        return rb
    }()

    public var flixType: FlixObjectType = .uninit
    public var position: Vector3 {
        get { rigidbody.position.vector3 }
        set { rigidbody.position = newValue.phyVector3 }
    }
    public var color: Color = .gray
    public var rotation: PHYQuaternion {
        get { rigidbody.orientation }
        set { rigidbody.orientation = newValue }
    }
    public var constrainPlane: Bool = true
    public var wireframe: Bool = false
    public var wireframeColor: Color = .white

    public var id: Int = 0
    public static func == (lhs: FlixObject, rhs: FlixObject) -> Bool {
        lhs.id == rhs.id
    }
    private func assignID() {
        id = FlixGame.itemID
        FlixGame.itemID += 1
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public init(rigidbody: PHYRigidBody) {
        self.rigidbody = rigidbody
    }

    deinit {
        if !isStaticInstanced, let model = model {
            Raylib.unloadModel(model)
        }
    }

    public func insertIntoDrawList() {
        assignID()
        if flixType == .uninit {
            fatalError("Must declare flixType before inserting into draw list")
        }
        FlixGame.drawList3D.append(self)
        if self is FlixDraws2D { FlixGame.drawList2D.append(self) }
        if usesPhysicsWorld {
            FlixGame.physicsWorld.add(rigidbody)
            FlixGame.rigidbodyToFlixObject[rigidbody] = self
        }
    }

    private func removeFromDrawList() {
        FlixGame.drawList3D.swapRemove(self)
        if self is FlixDraws2D { FlixGame.drawList2D.swapRemove(self) }
        if usesPhysicsWorld {
            FlixGame.rigidbodyToFlixObject.removeValue(forKey: rigidbody)
            FlixGame.physicsWorld.remove(rigidbody)
        }
    }

    public func update(dt: Float) {}

    public func handleDraw() {}

    func die() {
        if isDying {
            return
        }
        isDying = true
        removeFromDrawList()
    }
}
