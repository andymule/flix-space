import PhyKit
import Raylib
import RaylibC
import simd

// GLSL 4.1

class FlixGame {
  let physicsWorld = PHYWorld()
  var drawList: [FlixGFX] = .init()
  var inputList: [FlixInput] = .init()

  public func run() {
    let screenWidth: Int32 = 800
    let screenHeight: Int32 = 450
    Raylib.setConfigFlags(.msaa4xHint | .vsyncHint)
    Raylib.initWindow(screenWidth, screenHeight, "FlixGame")
    Raylib.setTargetFPS(90)

    var camera = Camera3D(
      position: Vector3(x: 0.0, y: 0.0, z: 10.0),
      target: Vector3(x: 0.0, y: 0.0, z: 0.0),
      up: Vector3(x: 0.0, y: 1.0, z: 0.0),
      fovy: 45.0,
      _projection: 0)  // CAMERA_PERSPECTIVE

    physicsWorld.gravity = PHYVector3(x: 0, y: 0, z: 0)  // y = -9.8

    makeBoxes(20)
    makeWalls()

    var ship = FlixShip(
      pos: Vector3(x: 0, y: 0, z: 0),
      scale: 0.2,
      color: .white,
      isStatic: false)
    ship.constrainPlane = true
    ship.rigidbody.angularVelocity = PHYVector3(x: 0, y: 0, z: 0)
    inputList.append(ship)
    physicsWorld.add(ship.rigidbody)
    drawList.append(ship)

    while Raylib.windowShouldClose == false {
      inputList.forEach { $0.handleInput() }

      // update time
      let deltaTime = Raylib.getFrameTime()
      // let time = Raylib.getTime()
      physicsWorld.internalStepSimulation(TimeInterval(deltaTime))
      camera.target = ship.position

      Raylib.beginDrawing()
      Raylib.clearBackground(.myDarkGrey)
      Raylib.beginMode3D(camera)
      drawList.forEach { $0.handleDraw() }
      Raylib.endMode3D()
      // Raylib.drawFPS(10, 10)
      Raylib.endDrawing()
    }
    Raylib.closeWindow()
  }

  func makeBoxes(_ count: Int) {
    for _ in 0..<count {
      var box: FlixBox = FlixBox(
        pos: Vector3(x: .random(in: -7...7), y: .random(in: -4...4), z: 0),
        size: Vector3(x: Float.random(in: 0.1...0.7), y: Float.random(in: 0.1...0.7), z: Float.random(in: 0.1...0.7)),
        color: .brown,
        isStatic: false)
      box.rotation = .euler(Float.random(in: 0..<360), Float.random(in: 0..<360), Float.random(in: 0..<360), .degrees)
      box.rigidbody.angularVelocity = PHYVector3(Float.random(in: -2..<2), Float.random(in: -2..<2), Float.random(in: -2..<2))
      box.rigidbody.linearVelocity = PHYVector3(Float.random(in: -2..<2), Float.random(in: -2..<2), 0)
      physicsWorld.add(box.rigidbody)
      drawList.append(box)
    }
  }

  func makeWalls() {
    let wallLeft = FlixBox(
      pos: Vector3(x: -7, y: 0, z: 0),
      size: Vector3(x: 0.1, y: 100, z: 0.1),
      color: .rayWhite,
      isStatic: true)
    let wallRight = FlixBox(
      pos: Vector3(x: 7, y: 0, z: 0),
      size: Vector3(x: 0.1, y: 100, z: 0.1),
      color: .rayWhite,
      isStatic: true)
    let wallTop = FlixBox(
      pos: Vector3(x: 0, y: 4, z: 0),
      size: Vector3(x: 100, y: 0.1, z: 0.1),
      color: .rayWhite,
      isStatic: true)
    let wallBottom = FlixBox(
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
