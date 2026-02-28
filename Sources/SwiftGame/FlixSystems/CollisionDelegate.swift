import PhyKit
import Raylib
import RaylibC
import simd

class CollisionDelegate: PHYWorldCollisionDelegate, PHYWorldTriggerDelegate, PHYWorldSimulationDelegate {

    func physicsWorld(
        _ physicsWorld: PhyKit.PHYWorld, triggerDidBeginAtTime time: TimeInterval, with collisionPair: PhyKit.PHYTriggerPair
    ) {}

    func physicsWorld(
        _ physicsWorld: PhyKit.PHYWorld, triggerDidContinueAtTime time: TimeInterval, with collisionPair: PhyKit.PHYTriggerPair
    ) {}

    func physicsWorld(
        _ physicsWorld: PhyKit.PHYWorld, triggerDidEndAtTime time: TimeInterval, with collisionPair: PhyKit.PHYTriggerPair
    ) {}

    func physicsWorld(_ physicsWorld: PhyKit.PHYWorld, willSimulateAtTime time: TimeInterval) {
        for p in FlixGame.planetList {
            for (_, o) in FlixGame.rigidbodyToFlixObject {
                let type = o.flixType
                guard type == .asteroid || type == .bullet || type == .ship else { continue }
                let dist = p.position.distance(o.position)
                guard dist > 0.01 else { continue }
                if dist < p.radiusInfluence {
                    if type == .ship, let ship = o as? FlixShip {
                        ship.isInfluencedCurrently = true
                    }
                    let force: Vector3 = (p.position - o.position) / (dist * dist)
                    o.rigidbody.applyForce(force.scale(FlixGame.gravityForceScale).phyVector3, impulse: false)
                }
            }
        }
    }

    fileprivate var markedForRemoval: Set<FlixObject> = .init()
    fileprivate func removeFromScene(_ obj: FlixObject) {
        markedForRemoval.insert(obj)
    }
    fileprivate func resolveRemovals() {
        for obj in markedForRemoval { obj.die() }
        markedForRemoval.removeAll()
    }

    func physicsWorld(_ physicsWorld: PhyKit.PHYWorld, didSimulateAtTime time: TimeInterval) {
        resolveRemovals()
    }

    func explodeShotStroid(_ object1: FlixObject, _ object2: FlixObject) {
        if object1.flixType == .bullet {
            (object1 as? Explodable)?.explode(nil)
            (object2 as? Explodable)?.explode(.impactFrom(object1.rigidbody))
        } else {
            (object1 as? Explodable)?.explode(.impactFrom(object2.rigidbody))
            (object2 as? Explodable)?.explode(nil)
        }
        removeFromScene(object1)
        removeFromScene(object2)
    }

    func explodeStroidHitPlanet(_ object1: FlixObject, _ object2: FlixObject) {
        if object1.flixType == .asteroid {
            (object1 as? Explodable)?.explode(nil)
            removeFromScene(object1)
        } else {
            (object2 as? Explodable)?.explode(nil)
            removeFromScene(object2)
        }
    }

    func physicsWorld(
        _ physicsWorld: PhyKit.PHYWorld, collisionDidBeginAtTime time: TimeInterval, with collisionPair: PhyKit.PHYCollisionPair
    ) {
        guard let bodyA = collisionPair.rigidBodyA,
              let bodyB = collisionPair.rigidBodyB,
              let flixObjA = FlixGame.rigidbodyToFlixObject[bodyA],
              let flixObjB = FlixGame.rigidbodyToFlixObject[bodyB] else { return }

        switch (flixObjA.flixType, flixObjB.flixType) {
        case (.bullet, .asteroid), (.asteroid, .bullet):
            explodeShotStroid(flixObjA, flixObjB)
        case (.asteroid, .planet), (.planet, .asteroid):
            explodeStroidHitPlanet(flixObjA, flixObjB)
        default:
            break
        }
    }

    func physicsWorld(
        _ physicsWorld: PhyKit.PHYWorld, collisionDidContinueAtTime time: TimeInterval,
        with collisionPair: PhyKit.PHYCollisionPair
    ) {}

    func physicsWorld(
        _ physicsWorld: PhyKit.PHYWorld, collisionDidEndAtTime time: TimeInterval, with collisionPair: PhyKit.PHYCollisionPair
    ) {}
}
