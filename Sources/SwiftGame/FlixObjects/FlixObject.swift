import PhyKit
import Raylib
import RaylibC
import simd

public class FlixObject: Equatable, Hashable {
    // TODO remove isStaticInstanced for all objects or implement for al objects?
    public var isStaticInstanced = false  // use a static model for all shared types
    public var isDying = false

    public var model: Model? = nil
    public var rigidbody: PHYRigidBody? = nil

    public var flixType: FlixObjectType = .uninit
    public var position: Vector3 {
        get {
            rigidbody!.position.vector3
        }
        set {
            rigidbody?.position = newValue.phyVector3
        }
    }
    public var color: Color = .gray
    public var rotation: PHYQuaternion {
        get {
            rigidbody!.orientation
        }
        set {
            rigidbody?.orientation = newValue
        }
    }
    public var constrainPlane: Bool = true
    public var wireframe: Bool = false
    public var wireframeColor: Color = .white

    // make equateable for better array/set handling
    public var _id: Int = 0
    public static func == (lhs: FlixObject, rhs: FlixObject) -> Bool {
        lhs._id == rhs._id
    }
    private func assignID() {
        _id = FlixGame.itemID
        FlixGame.itemID += 1
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(_id)
    }

    public func insertIntoDrawList() {
        assignID()
        if flixType == .uninit {
            fatalError("Must declare flixType before inserting into draw list")
        }
        FlixGame.drawList3D.append(self)
        if self is FlixDraws2D { FlixGame.drawList2D.append(self) }
        guard let rigidbody = rigidbody else { return }
        FlixGame.physicsWorld.add(rigidbody)
        FlixGame.rigidbodyToFlixObject[rigidbody] = self
    }

    // call from children via die()
    private func removeFromDrawList() {
        FlixGame.drawList3D.removeFirstEqualItem(self)
        if !isStaticInstanced && model != nil {
            Raylib.unloadModel(model!)
        }
        if self is FlixDraws2D { FlixGame.drawList2D.removeFirstEqualItem(self) }
        guard let rigidbody = rigidbody else { return }
        FlixGame.rigidbodyToFlixObject.removeValue(forKey: rigidbody)
        FlixGame.physicsWorld.remove(rigidbody)
    }

    public func handleDraw() {
        fatalError("Must Override")
    }

    public func explode(_ callbackData: FlixCallBackData? = nil) {
        fatalError("Must Override")
    }

    func die() {
        if isDying {
            return
        }
        isDying = true
        removeFromDrawList()
    }
}
