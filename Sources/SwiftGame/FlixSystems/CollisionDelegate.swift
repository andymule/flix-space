import PhyKit
import Raylib
import RaylibC
import simd

class CollisionDelegate: PHYWorldCollisionDelegate, PHYWorldTriggerDelegate, PHYWorldSimulationDelegate {
  var markedForRemoval: Set<FlixObject> = .init()

  func physicsWorld(
    _ physicsWorld: PhyKit.PHYWorld, triggerDidBeginAtTime time: TimeInterval, with collisionPair: PhyKit.PHYTriggerPair
  ) {
    print(collisionPair.rigidBody.className, collisionPair.trigger.className)
  }

  func physicsWorld(
    _ physicsWorld: PhyKit.PHYWorld, triggerDidContinueAtTime time: TimeInterval, with collisionPair: PhyKit.PHYTriggerPair
  ) {
    print(collisionPair.rigidBody.className, collisionPair.trigger.className)
  }

  func physicsWorld(
    _ physicsWorld: PhyKit.PHYWorld, triggerDidEndAtTime time: TimeInterval, with collisionPair: PhyKit.PHYTriggerPair
  ) {
    print(collisionPair.rigidBody.className, collisionPair.trigger.className)
  }

  func physicsWorld(_ physicsWorld: PhyKit.PHYWorld, willSimulateAtTime time: TimeInterval) {
    // print("callback1")
  }

  func physicsWorld(_ physicsWorld: PhyKit.PHYWorld, didSimulateAtTime time: TimeInterval) {
    // print("callback2")
  }

  func physicsWorld(
    _ physicsWorld: PhyKit.PHYWorld, collisionDidBeginAtTime time: TimeInterval, with collisionPair: PhyKit.PHYCollisionPair
  ) {
    let flixObjA: FlixObject = FlixGame.rigidbodyToFlixObject[collisionPair.rigidBodyA!]!
    let flixObjB: FlixObject = FlixGame.rigidbodyToFlixObject[collisionPair.rigidBodyB!]!
    if flixObjA.flixType == .bullet && flixObjB.flixType == .asteroid {
      flixObjA.explode()
      flixObjB.explode()
      markedForRemoval.insert(flixObjA)
      markedForRemoval.insert(flixObjB)
    } else if flixObjA.flixType == .asteroid && flixObjB.flixType == .bullet {
      flixObjA.explode()
      flixObjB.explode()
      markedForRemoval.insert(flixObjA)
      markedForRemoval.insert(flixObjB)
    }
  }

  func resolveRemovals() {
    for flixObj in markedForRemoval {
      flixObj.die()
    }
    markedForRemoval.removeAll()
  }

  func physicsWorld(
    _ physicsWorld: PhyKit.PHYWorld, collisionDidContinueAtTime time: TimeInterval, with collisionPair: PhyKit.PHYCollisionPair
  ) {
    //  print(collisionPair.rigidBodyA!.className, collisionPair.rigidBodyB!.className)
  }

  func physicsWorld(
    _ physicsWorld: PhyKit.PHYWorld, collisionDidEndAtTime time: TimeInterval, with collisionPair: PhyKit.PHYCollisionPair
  ) {
    //  print(collisionPair.rigidBodyA!.className, collisionPair.rigidBodyB!.className)
  }
  //    if collision.nodeA.name == "player" && collision.nodeB.name == "enemy" {
}

// make the collision layers
// let layer1: PHYCollisionLayer = PHYCollisionLayer(name: "layer1")
