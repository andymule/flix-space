import PhyKit
import Raylib
import RaylibC
import simd

// GLSL 4.1

class FlixGame {
  static let physicsWorld = PHYWorld()
  static var drawList: [FlixGFX] = .init()
  static var inputList: [FlixInput] = .init()
  static var camera: Camera3D = Camera3D(
    position: Vector3(x: 0.0, y: 0.0, z: 10.0),
    target: Vector3(x: 0.0, y: 0.0, z: 0.0),
    up: Vector3(x: 0.0, y: 1.0, z: 0.0),
    fovy: 45.0,
    _projection: 0)  // CAMERA_PERSPECTIVE
  var ship: FlixShip

  public init() {
    let screenWidth: Int32 = 800
    let screenHeight: Int32 = 450

    Raylib.setConfigFlags(.msaa4xHint | .vsyncHint)
    Raylib.initWindow(screenWidth, screenHeight, "FlixGame")
    Raylib.setTargetFPS(90)

    FlixGame.physicsWorld.gravity = PHYVector3(x: 0, y: 0, z: 0)  // y = -9.8

    ship = FlixShip(
      pos: Vector3(x: 0, y: 0, z: 0),
      scale: 0.2,
      color: .white,
      isStatic: false)
    ship.constrainPlane = true
    ship.rigidbody.angularVelocity = PHYVector3(x: 0, y: 0, z: 0)

    makeBoxes(20)
    makeWalls()
  }

  public func run() {
    while Raylib.windowShouldClose == false {
      FlixGame.inputList.forEach { $0.handleInput() }

      // update time
      let deltaTime = Raylib.getFrameTime()
      // let time = Raylib.getTime()
      FlixGame.physicsWorld.internalStepSimulation(TimeInterval(deltaTime))
      FlixGame.camera.target = ship.position

      Raylib.beginDrawing()
      Raylib.clearBackground(.myDarkGrey)
      Raylib.beginMode3D(FlixGame.camera)
      FlixGame.drawList.forEach { $0.handleDraw() }
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
    }
  }

  func makeWalls() {
    _ = FlixBox(
      pos: Vector3(x: -70, y: 0, z: 0),
      size: Vector3(x: 0.1, y: 1000, z: 0.1),
      color: .rayWhite,
      isStatic: true)
    _ = FlixBox(
      pos: Vector3(x: 70, y: 0, z: 0),
      size: Vector3(x: 0.1, y: 1000, z: 0.1),
      color: .rayWhite,
      isStatic: true)
    _ = FlixBox(
      pos: Vector3(x: 0, y: 40, z: 0),
      size: Vector3(x: 1000, y: 0.1, z: 0.1),
      color: .rayWhite,
      isStatic: true)
    _ = FlixBox(
      pos: Vector3(x: 0, y: -40, z: 0),
      size: Vector3(x: 1000, y: 0.1, z: 0.1),
      color: .rayWhite,
      isStatic: true)
  }
}
