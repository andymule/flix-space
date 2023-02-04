import PhyKit
import Raylib
import RaylibC
import simd

// GLSL 4.1

class FlixGame {
  public func run() {
    var drawList: [FlixGFX] = .init()
    var inputList: [FlixInput] = .init()
    let physicsWorld = PHYWorld()

    let screenWidth: Int32 = 800
    let screenHeight: Int32 = 450
    Raylib.setConfigFlags(.msaa4xHint | .vsyncHint)
    // Raylib.setConfigFlags(.vsyncHint)
    Raylib.initWindow(screenWidth, screenHeight, "FlixGame")
    Raylib.setTargetFPS(90)

    var camera = Camera3D(
      position: Vector3(x: 0.0, y: 0.0, z: 10.0),
      target: Vector3(x: 0.0, y: 0.0, z: 0.0),
      up: Vector3(x: 0.0, y: 1.0, z: 0.0),
      fovy: 45.0,
      _projection: 0)  // CAMERA_PERSPECTIVE

    physicsWorld.gravity = PHYVector3(x: 0, y: 0, z: 0)  // y = -9.8

    for _ in 0..<20 {
      var box = FlixBox(
        pos: Vector3(x: .random(in: -7...7), y: .random(in: -4...4), z: 0),
        size: Vector3(0.3),
        color: .brown,
        isStatic: false)
      box.rotation = .euler(Float.random(in: 0..<360), Float.random(in: 0..<360), Float.random(in: 0..<360), .degrees)
      box.rigidbody.angularVelocity = PHYVector3(Float.random(in: -2..<2), Float.random(in: -2..<2), Float.random(in: -2..<2))
      box.rigidbody.linearVelocity = PHYVector3(Float.random(in: -2..<2), Float.random(in: -2..<2), 0)
      physicsWorld.add(box.rigidbody)
      drawList.append(box)
    }

    makeWalls()

    var ship = FlixShip(
      pos: Vector3(x: 0, y: 0, z: 0),
      size: Vector3(0.2),
      color: .white,
      isStatic: false)
    ship.constrainPlane = true
    ship.rotation = .euler(270, 0, 0, .degrees)  //RaylibC.QuaternionFromEuler(45, 45, 0)
    ship.rigidbody.angularVelocity = PHYVector3(x: 0, y: 0, z: 0)
    inputList.append(ship)
    physicsWorld.add(ship.rigidbody)
    drawList.append(ship)

    while Raylib.windowShouldClose == false {
      inputList.forEach { $0.handleInput() }

      // update time
      let lastFrameTime = Raylib.getFrameTime()
      let time = Raylib.getTime()

      physicsWorld.internalStepSimulation(TimeInterval(lastFrameTime))

      Raylib.beginDrawing()
      Raylib.clearBackground(.myDarkGrey)

      Raylib.beginMode3D(camera)
      drawList.forEach { $0.handleDraw() }
      Raylib.endMode3D()
      Raylib.drawFPS(10, 10)
      Raylib.endDrawing()
    }
    Raylib.closeWindow()

    func makeWalls() {
      var wallLeft = FlixBox(
        pos: Vector3(x: -7, y: 0, z: 0),
        size: Vector3(x: 0.1, y: 100, z: 0.1),
        color: .rayWhite,
        isStatic: true)
      var wallRight = FlixBox(
        pos: Vector3(x: 7, y: 0, z: 0),
        size: Vector3(x: 0.1, y: 100, z: 0.1),
        color: .rayWhite,
        isStatic: true)
      var wallTop = FlixBox(
        pos: Vector3(x: 0, y: 4, z: 0),
        size: Vector3(x: 100, y: 0.1, z: 0.1),
        color: .rayWhite,
        isStatic: true)
      var wallBottom = FlixBox(
        pos: Vector3(x: 0, y: -4, z: 0),
        size: Vector3(x: 100, y: 0.1, z: 0.1),
        color: .rayWhite,
        isStatic: true)
      physicsWorld.add(wallLeft.rigidbody)
      drawList.append(wallLeft)
      physicsWorld.add(wallRight.rigidbody)
      drawList.append(wallRight)
      physicsWorld.add(wallTop.rigidbody)
      drawList.append(wallTop)
      physicsWorld.add(wallBottom.rigidbody)
      drawList.append(wallBottom)
    }
  }
}
