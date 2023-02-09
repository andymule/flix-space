import PhyKit
import Raylib
import RaylibC
import simd

public class FlixObject: FlixGFX, Equatable {
  public enum FlixObjectType {
    case ship
    case asteroid
    case bullet
    case explosion
    case explosionManager
    case camera
    case wall
    case uninit
    case other
  }
  public var flixType: FlixObjectType = .uninit
  public var position: Vector3 {
    get {
      rigidbody.position.vector3
    }
    set {
      rigidbody.position = newValue.phyVector3
    }
  }
  public var color: Color = .gray
  public var rotation: PHYQuaternion {
    get {
      rigidbody.orientation
    }
    set {
      rigidbody.orientation = newValue
    }
  }
  public var constrainPlane: Bool = true
  public var wireframe: Bool = false
  public var wireframeColor: Color = .white

  public var rigidbody: PHYRigidBody = PHYRigidBody(type: .dynamic, shape: PHYCollisionShapeBox(width: 1, height: 1, length: 1))
  public var mass: Float {
    get {
      rigidbody.type.mass
    }
  }

  // make equateable for better array handling
  public var _id: Int = 0
  public static func == (lhs: FlixObject, rhs: FlixObject) -> Bool {
    lhs._id == rhs._id
  }
  private func assignID() {
    _id = FlixGame.itemID
    FlixGame.itemID += 1
  }

  public func insertIntoDrawList() {
    assignID()
    if (flixType == .uninit) {
      fatalError("Must declare flixType before inserting into draw list")
    }
    FlixGame.drawList.append(self)
    FlixGame.physicsWorld.add(self.rigidbody)
    FlixGame.rigidbodyToFlixObject[rigidbody] = self
  }

  public func removeFromDrawList() {
    FlixGame.physicsWorld.remove(rigidbody)
    FlixGame.drawList.removeFirstEqualItem(self)
    FlixGame.rigidbodyToFlixObject.removeValue(forKey: rigidbody)
  }

  public func handleDraw() {
    fatalError("Must Override")
  }

  public func explode() {
    fatalError("Must Override")
  }
}
