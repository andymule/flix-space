import PhyKit
import Raylib
import RaylibC
import simd

@main
public struct SwiftGame {
  public static func main() {
    let screenWidth: Int32 = 800
    let screenHeight: Int32 = 450

    Raylib.initWindow(screenWidth, screenHeight, "MyGame")
    Raylib.setTargetFPS(90)

    var camera = Camera3D(
      position: Vector3(x: 0.0, y: 5.0, z: 10.0),
      target: Vector3(x: 0.0, y: 5.0, z: 0.0),
      up: Vector3(x: 0.0, y: 1.0, z: 0.0),
      fovy: 45.0,
      _projection: 0)  // CAMERA_PERSPECTIVE

    let physicsWorld = PHYWorld()
    physicsWorld.gravity = PHYVector3(x: 0, y: 0, z: 0) // y = -9.8

    var boxes: [FlixBox] = .init()

    for _ in 0..<1000 {
      var box = FlixBox(
        pos: Vector3(x: .random(in: -5...5), y: .random(in: 1...10), z: .random(in: -10...10)),
        size: Vector3(0.2),
        color: .pink,
        isStatic: false)
      box.constrainPlane = true
      box.rotation = .euler(
        Float.random(in: 0..<360), Float.random(in: 0..<360), Float.random(in: 0..<360), .degrees)  //RaylibC.QuaternionFromEuler(45, 45, 0)
      physicsWorld.add(box.rigidbody)
      boxes.append(box)
    }

    while Raylib.windowShouldClose == false {
      // update time and physics
      let lastFrameTime = Raylib.getFrameTime()
      let time = Raylib.getTime()
      physicsWorld.internalStepSimulation(TimeInterval(lastFrameTime))

      // Move camera around the scene
      // let cameraTime: Float = Float(time * 0.5)
      // camera.position.x = sinf(cameraTime) * 10.0
      // camera.position.z = cosf(cameraTime) * 10.0

      Raylib.beginDrawing()
      Raylib.clearBackground(.rayWhite)

      Raylib.beginMode3D(camera)
      for box in boxes {
        box.draw()
      }
      // Raylib.drawGrid(100, 1.0)
      Raylib.endMode3D()
      Raylib.drawFPS(10, 10)
      Raylib.endDrawing()
    }
    Raylib.closeWindow()
  }
}
