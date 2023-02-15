import PhyKit
import Raylib
import RaylibC
import simd

public class FlixPlanet: FlixObject {
    let radius: Float
    let radiusInfluence: Float
    let texture: Texture2D
    let rotationSpeed: Float = 0.002
    var axisRotation: Float = 0.0
    let modelWire: Model?
    public init(position: Vector3, radius: Float, color: Color, flixType: FlixObjectType) { //mass?
        self.radius = radius
        self.radiusInfluence = radius * 4
        texture = LoadTexture(Bundle.module.path(forResource: "Icy", ofType: "png")! ) //"Resources/planets/Icy.png"
        let shape = Raylib.genMeshSphere(radius, 32, 32)
        let shapeBigger = Raylib.genMeshSphere(radiusInfluence, 6, 32)
        modelWire = Raylib.loadModelFromMesh(shapeBigger)
        super.init()
        self.color = color
        model = Raylib.loadModelFromMesh(shape)
        model!.materials[0].maps[0].texture = texture
        rigidbody = PHYRigidBody(type: .static, shape: PHYCollisionShapeSphere(radius: radius))
        rigidbody?.position = position.phyVector3
        rigidbody?.linearDamping = 0.0
        rigidbody?.angularDamping = 0.0
        rigidbody?.friction = 1.0
        rigidbody?.restitution = 0.0
        rigidbody?.isSleepingEnabled = false
        rigidbody?.eulerOrientation = Vector3(x: 90, y: 0, z: 0).phyVector3
        self.color = color
        self.flixType = flixType
        insertIntoDrawList()
    }

    override public func handleDraw() {
        axisRotation += rotationSpeed
        axisRotation = axisRotation.truncatingRemainder(dividingBy: 360)
        rigidbody?.eulerOrientation = Vector3(x: 90, y: 0, z: axisRotation).phyVector3
        let (axis, angle) = rigidbody!.orientation.vector4.toAxisAngle()
        let angle2 = angle * 180 / Float.pi
        //centerPos: Vector3, radius: Float, rings: Int32, slices: Int32, color: Color)
        // Raylib.drawSphereWires(rigidbody!.position.vector3, radiusInfluence, 32, 32, Color(r: 255, g: 255, b: 0, a: 25))
        Raylib.drawModelEx(
            model!, rigidbody!.position.vector3, axis, angle2, Vector3(x: 1.0, y: 0.004, z: 1.0), Color(r: 222, g: 222, b: 222, a: 255))
        Raylib.drawModelWiresEx(
            modelWire!, rigidbody!.position.vector3, Vector3(x: 0.0, y: 0.0, z: 1.0), angle2 * 2, Vector3(x: 1.0, y: 1.0, z: 0.0001),
            Color(r: 255, g: 255, b: 0, a: 13))
    }
}
