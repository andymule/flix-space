import PhyKit
import Raylib
import RaylibC
import simd

class CollisionDelegate: PHYWorldCollisionDelegate, PHYWorldTriggerDelegate, PHYWorldSimulationDelegate {

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
            for o in FlixGame.drawList3D where (o.flixType == .asteroid || o.flixType == .bullet || o.flixType == .ship) {
                let dist = p.position.distance(o.position)
                if dist < p.radiusInfluence {
                    if o.flixType == .ship {
                        (o as! FlixShip).isInfluencedCurrently = true
                    }
                    let force: Vector3 = (p.position - o.position) / (dist * dist)
                    o.rigidbody?.applyForce(force.scale(6).phyVector3, impulse: false)
                }
            }
        }
    }

    fileprivate var markedForRemoval: Set<FlixObject> = .init()
    fileprivate func removeFromScene(_ obj: FlixObject) {
        markedForRemoval.insert(obj)
    }
    fileprivate func resolveRemovals() {
        markedForRemoval.forEach { $0.die() }  // might be redudant but die() checks for that
        markedForRemoval.removeAll()
    }

    func physicsWorld(_ physicsWorld: PhyKit.PHYWorld, didSimulateAtTime time: TimeInterval) {
        resolveRemovals()
    }

    func explodeShotStroid(_ object1: FlixObject, _ object2: FlixObject) {
        if object1.flixType == .bullet {
            object1.explode()  // Bullet explodes normally
            object2.explode(FlixCallBackData(rigidbodies: [object1.rigidbody]))  // Asteroid explodes with callback data
        } else {
            object1.explode(FlixCallBackData(rigidbodies: [object2.rigidbody]))  // Asteroid explodes with callback data
            object2.explode()  // Bullet explodes normally
        }
        removeFromScene(object1)
        removeFromScene(object2)
    }

    func explodeStroidHitPlanet(_ object1: FlixObject, _ object2: FlixObject) {
        if object1.flixType == .asteroid {
            object1.explode()
            removeFromScene(object1)
        } else {
            object2.explode()
            removeFromScene(object2)
        }
    }

    func physicsWorld(
        _ physicsWorld: PhyKit.PHYWorld, collisionDidBeginAtTime time: TimeInterval, with collisionPair: PhyKit.PHYCollisionPair
    ) {
        let flixObjA: FlixObject = FlixGame.rigidbodyToFlixObject[collisionPair.rigidBodyA!]!
        let flixObjB: FlixObject = FlixGame.rigidbodyToFlixObject[collisionPair.rigidBodyB!]!

        switch (flixObjA.flixType, flixObjB.flixType) {
        case (.bullet, .asteroid), (.asteroid, .bullet):
            explodeShotStroid(flixObjA, flixObjB)
        case (.asteroid, .planet), (.planet, .asteroid):
            explodeStroidHitPlanet(flixObjA, flixObjB)
        default:
            break  // Do nothing for other combinations
        }
    }

    func physicsWorld(
        _ physicsWorld: PhyKit.PHYWorld, collisionDidContinueAtTime time: TimeInterval,
        with collisionPair: PhyKit.PHYCollisionPair
    ) {
        //  TODO can I remove this?

    }

    func physicsWorld(
        _ physicsWorld: PhyKit.PHYWorld, collisionDidEndAtTime time: TimeInterval, with collisionPair: PhyKit.PHYCollisionPair
    ) {
        //  print(collisionPair.rigidBodyA!.className, collisionPair.rigidBodyB!.className)
    }
}
