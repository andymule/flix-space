import PhyKit
import Raylib
import RaylibC
import simd

class CollisionDelegate: PHYWorldCollisionDelegate, PHYWorldTriggerDelegate, PHYWorldSimulationDelegate {
  var markedForRemoval: Set<FlixObject> = .init()

  func physicsWorld(
    _ physicsWorld: PhyKit.PHYWorld, triggerDidBeginAtTime time: TimeInterval, with collisionPair: PhyKit.PHYTriggerPair
  ) {
    // print(collisionPair.rigidBody.className, collisionPair.trigger.className)
  }

  func physicsWorld(
    _ physicsWorld: PhyKit.PHYWorld, triggerDidContinueAtTime time: TimeInterval, with collisionPair: PhyKit.PHYTriggerPair
  ) {
    // print(collisionPair.rigidBody.className, collisionPair.trigger.className)
  }

  func physicsWorld(
    _ physicsWorld: PhyKit.PHYWorld, triggerDidEndAtTime time: TimeInterval, with collisionPair: PhyKit.PHYTriggerPair
  ) {
    // print(collisionPair.rigidBody.className, collisionPair.trigger.className)
  }

  func physicsWorld(_ physicsWorld: PhyKit.PHYWorld, willSimulateAtTime time: TimeInterval) {
    for p in FlixGame.planetList {
      for o in FlixGame.drawList where (o.flixType == .asteroid || o.flixType == .bullet || o.flixType == .ship) {
        let dist = p.position.distance(o.position)
        if dist < p.radiusInfluence {
          if o.flixType == .ship {
            (o as! FlixShip).isInfluencedCurrently = true
          }
          let force: Vector3 = (p.position - o.position) / (dist * dist)
          o.rigidbody?.applyForce(force.phyVector3, impulse: false)
        }
      }
    }
  }

  private func resolveRemovals() {
    markedForRemoval.forEach { $0.die() }  // might be redudant but die() checks for that
    markedForRemoval.removeAll()
  }

  func physicsWorld(_ physicsWorld: PhyKit.PHYWorld, didSimulateAtTime time: TimeInterval) {
    resolveRemovals()
  }

  func physicsWorld(
    _ physicsWorld: PhyKit.PHYWorld, collisionDidBeginAtTime time: TimeInterval, with collisionPair: PhyKit.PHYCollisionPair
  ) {
    let flixObjA: FlixObject = FlixGame.rigidbodyToFlixObject[collisionPair.rigidBodyA!]!
    let flixObjB: FlixObject = FlixGame.rigidbodyToFlixObject[collisionPair.rigidBodyB!]!
    if flixObjA.flixType == .bullet && flixObjB.flixType == .asteroid {
      flixObjA.explode()
      flixObjB.explode(FlixCallBackData(rigidbodies: [flixObjA.rigidbody]))
      markedForRemoval.insert(flixObjA)
      markedForRemoval.insert(flixObjB)
    } else if flixObjA.flixType == .asteroid && flixObjB.flixType == .bullet {
      flixObjA.explode(FlixCallBackData(rigidbodies: [flixObjB.rigidbody]))
      flixObjB.explode()
      markedForRemoval.insert(flixObjA)
      markedForRemoval.insert(flixObjB)
    } else if flixObjA.flixType == .asteroid && flixObjB.flixType == .planet {
      flixObjA.explode()
      markedForRemoval.insert(flixObjA)
    } else if flixObjA.flixType == .planet && flixObjB.flixType == .asteroid {
      flixObjB.explode()
      markedForRemoval.insert(flixObjB)
    }
  }

  func physicsWorld(
    _ physicsWorld: PhyKit.PHYWorld, collisionDidContinueAtTime time: TimeInterval, with collisionPair: PhyKit.PHYCollisionPair
  ) {
    //  TODO can I remove this?

  }

  func physicsWorld(
    _ physicsWorld: PhyKit.PHYWorld, collisionDidEndAtTime time: TimeInterval, with collisionPair: PhyKit.PHYCollisionPair
  ) {
    //  print(collisionPair.rigidBodyA!.className, collisionPair.rigidBodyB!.className)
  }
}
