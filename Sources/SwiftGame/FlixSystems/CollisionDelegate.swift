import PhyKit
import Raylib
import RaylibC
import simd

class CollisionDelegate : PHYWorldCollisionDelegate {
    func physicsWorld(_ physicsWorld: PhyKit.PHYWorld, collisionDidBeginAtTime time: TimeInterval, with collisionPair: PhyKit.PHYCollisionPair) {
        
    }

    func physicsWorld(_ physicsWorld: PhyKit.PHYWorld, collisionDidContinueAtTime time: TimeInterval, with collisionPair: PhyKit.PHYCollisionPair) {
        
    }

    func physicsWorld(_ physicsWorld: PhyKit.PHYWorld, collisionDidEndAtTime time: TimeInterval, with collisionPair: PhyKit.PHYCollisionPair) {
        
    }

//    if collision.nodeA.name == "player" && collision.nodeB.name == "enemy" {
}
