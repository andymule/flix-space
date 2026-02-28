import PhyKit
import Raylib
import RaylibC
import simd

public class FlixTriangle: FlixObject {
    private var localA: Vector3
    private var localB: Vector3
    private var localC: Vector3
    private var linVel: Vector3
    private var angVel: Vector3
    private var pos: Vector3
    private var orient: Quaternion
    private let linDamp: Float = 0.3
    private let angDamp: Float = 0.3

    public init(triangle: Triangle, startingBody: PHYRigidBody, color: Color, collidingBody: PHYRigidBody? = nil) {
        self.localA = triangle.a
        self.localB = triangle.b
        self.localC = triangle.c

        let startLinVel = startingBody.linearVelocity.vector3.scale(0.5)
        let impactVel = collidingBody?.linearVelocity.vector3.scale(.random(in: 0.2...0.5)) ?? .zero
        self.linVel = startLinVel + impactVel
        self.angVel = startingBody.angularVelocity.vector3.scale(.random(in: -1.0...1.0))
        self.pos = startingBody.position.vector3
        self.orient = startingBody.orientation.quaternion

        super.init(rigidbody: FlixObject.dummyRigidbody)
        self.usesPhysicsWorld = false
        self.color = color
        self.flixType = .triangle
        self.isStaticInstanced = true
        insertIntoDrawList()
    }

    override public func update(dt: Float) {
        if isDying { return }
        let dampLin = max(0, 1.0 - linDamp * dt)
        linVel = linVel.scale(dampLin)
        pos = pos + linVel.scale(dt)
        if constrainPlane { pos.z = 0 }

        let dampAng = max(0, 1.0 - angDamp * dt)
        angVel = angVel.scale(dampAng)
        let angMag = angVel.length
        if angMag > 0.001 {
            let axis = angVel.scale(1.0 / angMag)
            let dq = RaylibC.QuaternionFromAxisAngle(axis, angMag * dt)
            orient = RaylibC.QuaternionMultiply(dq, orient)
        }
    }

    override public func handleDraw() {
        let wa = pos + RaylibC.Vector3RotateByQuaternion(localA, orient)
        let wb = pos + RaylibC.Vector3RotateByQuaternion(localB, orient)
        let wc = pos + RaylibC.Vector3RotateByQuaternion(localC, orient)
        DrawTriangle3D(wa, wb, wc, color)
        DrawTriangle3D(wc, wb, wa, color)
    }
}
