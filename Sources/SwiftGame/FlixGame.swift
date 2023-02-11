import PhyKit
import Raylib
import RaylibC
import simd

// GLSL 4.1

class FlixGame {
  static let physicsWorld: PHYWorld = PHYWorld()
  static var rigidbodyToFlixObject: [PHYRigidBody: FlixObject] = .init()  // used to trace back collisions to objects
  static var drawList: [FlixObject] = .init()
  static var inputList: [FlixInput] = .init()

  static var itemID: Int = 0  // used to assign unique IDs to objects
  static var deltaTime: Float = 0
  static var time: Double = 0

  var ship: FlixShip
  private let camera: FlixCamera = FlixCamera()

  let wallDist: Float = 70.0
  private var collisionDelegate: CollisionDelegate = CollisionDelegate()

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

    makeBoxes(700)
    makeWalls()
  }

  public func run() {
    FlixGame.physicsWorld.collisionDelegate = collisionDelegate
    FlixGame.physicsWorld.triggerDelegate = collisionDelegate
    FlixGame.physicsWorld.simulationDelegate = collisionDelegate

    while Raylib.windowShouldClose == false {
      FlixGame.inputList.forEach { $0.handleInput() }

      // update time
      FlixGame.deltaTime = Raylib.getFrameTime()
      FlixGame.time = Raylib.getTime()
      FlixGame.physicsWorld.simulationTime = FlixGame.time
      camera.update(ship: ship)

      draw()
    }
    Raylib.closeWindow()
  }

  func draw() {
    Raylib.beginDrawing()
    Raylib.clearBackground(.myDarkGrey)
    Raylib.beginMode3D(camera.camera)
    FlixGame.drawList.forEach { $0.handleDraw() }
    Raylib.endMode3D()
    // Raylib.drawFPS(10, 10)
    Raylib.endDrawing()
  }

  func makeBoxes(_ count: Int) {
    for _ in 0..<count {
      let box: FlixBox = FlixBox(
        pos: Vector3(x: .random(in: -wallDist...wallDist), y: .random(in: -wallDist...wallDist), z: 0),
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
      pos: Vector3(x: -wallDist, y: 0, z: 0),
      size: Vector3(x: 10, y: 1000, z: 0.1),
      color: .rayWhite,
      isStatic: true,
      flixType: .wall
    )
    _ = FlixBox(
      pos: Vector3(x: wallDist, y: 0, z: 0),
      size: Vector3(x: 10, y: 1000, z: 0.1),
      color: .rayWhite,
      isStatic: true,
      flixType: .wall)
    _ = FlixBox(
      pos: Vector3(x: 0, y: wallDist, z: 0),
      size: Vector3(x: 1000, y: 10, z: 0.1),
      color: .rayWhite,
      isStatic: true,
      flixType: .wall)
    _ = FlixBox(
      pos: Vector3(x: 0, y: -wallDist, z: 0),
      size: Vector3(x: 1000, y: 10, z: 0.1),
      color: .rayWhite,
      isStatic: true,
      flixType: .wall)
  }
}
