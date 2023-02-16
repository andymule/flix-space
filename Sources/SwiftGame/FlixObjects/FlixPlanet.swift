import PhyKit
import Raylib
import RaylibC
import simd

public class FlixPlanet: FlixObject, FlixDraws2D {
    class LandingPad {
        var rotationPosition: Int = 0  // where  from 0 - 360 is the pad currently?
        let padWidth: Float = 1.0
        let trigger: PHYRigidBody
        init() {
            trigger = PHYRigidBody(type: .static, shape: PHYCollisionShapeBox(size: padWidth))
            trigger.isSleepingEnabled = false
        }
    }

    let radius: Float
    let radiusInfluence: Float
    let texture: Texture2D
    let rotationSpeed: Float = 0.002
    var axisRotation: Float = 0.0
    let modelWire: Model?
    let scalar2D: Float
    var landingPad: LandingPad?

    public init(position: Vector3, radius: Float, color: Color, flixType: FlixObjectType) {
        self.radius = radius
        self.radiusInfluence = radius * 4
        self.scalar2D = Float(FlixGame.screenWidth) * radius / FlixGame.aspectRatio
        texture = LoadTexture(Bundle.module.path(forResource: "Icy", ofType: "png")!)
        let shape = Raylib.genMeshSphere(radius, 32, 32)
        let shapeBigger = Raylib.genMeshSphere(radiusInfluence, 3, 32)
        modelWire = Raylib.loadModelFromMesh(shapeBigger)
        super.init()
        self.color = color
        model = Raylib.loadModelFromMesh(shape)
        model!.materials[0].maps[0].texture = texture
        rigidbody = PHYRigidBody(type: .kinematic, shape: PHYCollisionShapeSphere(radius: radius))
        rigidbody?.position = position.phyVector3
        rigidbody?.linearDamping = 0.0
        rigidbody?.angularDamping = 0.0
        rigidbody?.friction = 1.0
        rigidbody?.restitution = 0.0
        rigidbody?.isSleepingEnabled = false
        self.color = color
        self.flixType = flixType
        insertIntoDrawList()
    }

    override public func handleDraw() {
        axisRotation += rotationSpeed
        axisRotation = axisRotation.truncatingRemainder(dividingBy: 2 * Float.pi)
        rigidbody?.eulerOrientation = Vector3(x: Float.pi / 2, y: 0, z: axisRotation).phyVector3
        let (axis, angle) = rigidbody!.orientation.vector4.toAxisAngle()
        let angle2 = angle * 180 / Float.pi
        // Raylib.drawSphereWires(rigidbody!.position.vector3, radiusInfluence, 32, 32, Color(r: 255, g: 255, b: 0, a: 25))
        let drawPos = rigidbody!.position.vector3
        Raylib.drawModelEx(model!, drawPos, axis, angle2, Vector3(x: 1.0, y: 1.0, z: 1.0), Color(r: 222, g: 222, b: 222, a: 255))
        let diff = radiusInfluence - radius
        let slices = 6
        let oneSliceSize = diff / Float(slices)
        let thisNudge = oneSliceSize * Float(FlixGame.time.remainder(dividingBy: 1.0))
        for i: Int in 0..<slices {
            let thisSize = radius + oneSliceSize * Float(i) - thisNudge
            Raylib.drawCircle3D(
                drawPos, thisSize, Vector3(0.0, 0.0, 1.0), 90,
                Color(r: 255, g: 255, b: 0, a: UInt8((1.0 - (thisSize / radiusInfluence)) * 255.0)))
        }
        Raylib.drawModelWiresEx(
            modelWire!, drawPos, Vector3(0.0, 0.0, 1.0), axisRotation * 180 / Float.pi, Vector3(x: 1.0, y: 1.0, z: 0.001),
            Color(r: 255, g: 255, b: 0, a: 25))
    }

    public func handleDraw2D() {
        let dpos: Vector2 = GetWorldToScreen(rigidbody!.position.vector3, FlixGame.cameras.camera3D)
		Raylib.drawCircleV(dpos, scalar2D / FlixGame.cameras.camera3D.fovy, Color(r: 255, g: 255, b: 0, a: 50))
    }
}
