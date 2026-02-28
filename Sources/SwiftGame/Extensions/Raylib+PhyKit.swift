import PhyKit
import Raylib
import RaylibC

/// Bridges Raylib and PhyKit for interop between rendering and physics types.

func RaylibGenSCNGeometryFromModel(model: Model, scale: Float, size: Vector3 = .one) -> SCNGeometry {
    let tempMesh: Mesh = model.meshes[0]
    let tVerts: UnsafeMutablePointer<Float>? = tempMesh.vertices
    var verticesConverted: [SCNVector3] = []
    for v: Int in 0..<Int(tempMesh.vertexCount) {
        let x: Float = tVerts![v * 3] * scale * size.x
        let y: Float = tVerts![v * 3 + 1] * scale * size.y
        let z: Float = tVerts![v * 3 + 2] * scale * size.z
        verticesConverted.append(SCNVector3(x, y, z))
    }
    let positionSource = SCNGeometrySource(vertices: verticesConverted)
    var indices: [UInt16] = .init()
    for i: Int in 0..<Int(tempMesh.triangleCount) {
        indices.append(UInt16(tempMesh.indices[i * 3]))
        indices.append(UInt16(tempMesh.indices[i * 3 + 1]))
        indices.append(UInt16(tempMesh.indices[i * 3 + 2]))
    }
    let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
    return SCNGeometry(sources: [positionSource], elements: [element])
}

func PHYRigidBodyFromRaylibModel(
    model: Model, scale: Float, isStatic: Bool, mass: Float,
    collisionType: PHYCollisionShapeGeometry.PHYCollisionShapeGeometryType,
    size: Vector3 = .one
) -> PHYRigidBody {
    let phyGeo = PHYGeometry(scnGeometry: RaylibGenSCNGeometryFromModel(model: model, scale: scale, size: size))
    let collisionShape = PHYCollisionShapeGeometry(geometry: phyGeo, type: .concave)
    return PHYRigidBody(type: isStatic ? .static : .dynamic(mass: mass), shape: collisionShape)
}

extension PHYVector3 {
    @inlinable
    public var vector3: Vector3 {
        Vector3(x: x, y: y, z: z)
    }
    @inlinable
    public var vector2: Vector2 {
        Vector2(x: x, y: y)
    }
    @inlinable
    public static func += (lhs: inout PHYVector3, rhs: PHYVector3) {
        lhs = PHYVector3(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }
    @inlinable
    public static func + (lhs: PHYVector3, rhs: PHYVector3) -> PHYVector3 {
        PHYVector3(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }
}

extension Vector3 {
    @inlinable
    public var phyVector3: PhyKit.PHYVector3 {
        PHYVector3(x: x, y: y, z: z)
    }
    @inlinable
    public var rads2degs: Vector3 {
        Vector3(x: x * 180 / Float.pi, y: y * 180 / Float.pi, z: z * 180 / Float.pi)
    }
    @inlinable
    public var degs2rads: Vector3 {
        Vector3(x: x * Float.pi / 180, y: y * Float.pi / 180, z: z * Float.pi / 180)
    }
    @inlinable
    init(_ uniform: Float) {
        self.init(x: uniform, y: uniform, z: uniform)
    }
    @inlinable
    init(_ x: Float, _ y: Float, _ z: Float) {
        self.init(x: x, y: y, z: z)
    }
    @inlinable
    static func random(in range: ClosedRange<Float>) -> Vector3 {
        Vector3(
            x: Float.random(in: range),
            y: Float.random(in: range),
            z: Float.random(in: range)
        )
    }
    @inlinable
    public var roundedTenths: Vector3 {
        Vector3(
            x: round(x * 10) / 10,
            y: round(y * 10) / 10,
            z: round(z * 10) / 10
        )
    }

    @inlinable
    public var rounded: Vector3 {
        Vector3(
            x: round(x),
            y: round(y),
            z: round(z)
        )
    }

    @inlinable
    static func / (lhs: Vector3, rhs: Vector3) -> Vector3 {
        Vector3(x: lhs.x / rhs.x, y: lhs.y / rhs.y, z: lhs.z / rhs.z)
    }
    @inlinable
    static func / (lhs: Vector3, rhs: Float) -> Vector3 {
        Vector3(x: lhs.x / rhs, y: lhs.y / rhs, z: lhs.z / rhs)
    }
    @inlinable
    static func / (lhs: Vector3, rhs: Int) -> Vector3 {
        let rhs = Float(rhs)
        return Vector3(x: lhs.x / rhs, y: lhs.y / rhs, z: lhs.z / rhs)
    }
}

extension Vector2 {
    public var phyVector3: PhyKit.PHYVector3 {
        PHYVector3(x: x, y: y, z: 0)
    }
}

extension PHYQuaternion {
    @inlinable
    public var vector4: Vector4 {
        Vector4(x: x, y: y, z: z, w: w)
    }
    @inlinable
    public var quaternion: Quaternion {
        Vector4(x: x, y: y, z: z, w: w)
    }
    @inlinable
    public func toAxisAngleRads() -> (PHYVector3, Float) {
        var axis: Vector3 = .zero
        var angle: Float = 0
        RaylibC.QuaternionToAxisAngle(self.vector4, &axis, &angle)
        return (axis.phyVector3, angle)
    }
    @inlinable
    public func toAxisAngleDegs() -> (PHYVector3, Float) {
        var axis: Vector3 = .zero
        var angle: Float = 0
        RaylibC.QuaternionToAxisAngle(self.vector4, &axis, &angle)
        return (axis.phyVector3, angle * 180 / Float.pi)
    }
    @inlinable
    public func toAxisAngleRads() -> (Vector3, Float) {
        var axis: Vector3 = .zero
        var angle: Float = 0
        RaylibC.QuaternionToAxisAngle(self.vector4, &axis, &angle)
        return (axis, angle)
    }
    @inlinable
    public func toAxisAngleDegs() -> (Vector3, Float) {
        var axis: Vector3 = .zero
        var angle: Float = 0
        RaylibC.QuaternionToAxisAngle(self.vector4, &axis, &angle)
        return (axis, angle * 180 / Float.pi)
    }

    @inlinable
    public func toEulerRads() -> PHYVector3 {
        RaylibC.QuaternionToEuler(self.vector4).phyVector3
    }
    @inlinable
    public func toEulerRads() -> Vector3 {
        RaylibC.QuaternionToEuler(self.vector4)
    }
    @inlinable
    public func toEulerDegs() -> PHYVector3 {
        RaylibC.QuaternionToEuler(self.vector4).rads2degs.phyVector3
    }
    @inlinable
    public func toEulerDegs() -> Vector3 {
        RaylibC.QuaternionToEuler(self.vector4).rads2degs
    }
}

extension Quaternion {
    @inlinable
    public var phyQuat: PHYQuaternion {
        PHYQuaternion(x: x, y: y, z: z, w: w)
    }
}
