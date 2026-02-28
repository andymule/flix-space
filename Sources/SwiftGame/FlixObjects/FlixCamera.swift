import PhyKit
import Raylib
import RaylibC
import simd

public class FlixCamera: FlixInput {
    public func handleInput() {
        if Raylib.isKeyDown(.number1) {
            camera3D.fovy = 35
        }
        if Raylib.isKeyDown(.number2) {
            camera3D.fovy = 65
        }
        if Raylib.isKeyDown(.number3) {
            camera3D.fovy = 103
        }
    }

    static let viewType: Float = 1
    static let startZoom: Float = 45.0
    static let maxZoom: Float = 90

    public var camera3D: Camera3D = Camera3D(
        position: Vector3(x: 0.0, y: 0.0, z: 20.0),
        target: Vector3(x: 0.0, y: 0.0, z: 0.0),
        up: Vector3(x: 0.0, y: 1.0, z: 0.0),
        fovy: startZoom,
        _projection: Int32(viewType))  // 0 CAMERA_PERSPECTIVE, 1 ORTHO

    public var camera2D: Camera2D = Camera2D(
        offset: Vector2(x: 0.0, y: 0.0),
        target: Vector2(x: 0.0, y: 0.0),
        rotation: 0.0,
        zoom: 1.0)

    public init() {
        insertIntoInputList()
    }

    public func update(ship: FlixShip) {
        camera3D.position = Vector3(x: ship.position.x, y: ship.position.y, z: 20)
        camera3D.target = ship.position
    }
}
