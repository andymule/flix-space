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

  private var collisionDelegate: CollisionDelegate = CollisionDelegate()

  public init() {
    let screenWidth: Int32 = 1400
    let screenHeight: Int32 = 900

    Raylib.setConfigFlags(.msaa4xHint | .vsyncHint)
    Raylib.setTraceLogLevel(.error)
    Raylib.initWindow(screenWidth, screenHeight, "FlixGame")
    Raylib.setTargetFPS(120)

    FlixGame.physicsWorld.gravity = PHYVector3(x: 0, y: 0, z: 0)  // y = -9.8

    ship = FlixShip(
      pos: Vector3(x: 0, y: 0, z: 0),
      scale: 0.2,
      color: .white,
      isStatic: false)

    let borderDistance: Float = 700.0
    makeWalls(borderDistance: borderDistance)
    makeBoxes(2000, borderDistance: borderDistance)
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
      // (FlixGame.physicsWorld.collisionDelegate as! CollisionDelegate).resolveRemovals() // resolved in simulation ended delegate, hopefully
      camera.update(ship: ship)

      draw()
    }
    Raylib.closeWindow()
  }

  func draw() {
    Raylib.beginDrawing()
    Raylib.clearBackground(.myDarkGreyFadey)
    Raylib.beginMode3D(camera.camera)
    FlixGame.drawList.forEach { $0.handleDraw() }
    Raylib.endMode3D()
    Raylib.drawFPS(10, 10)
    Raylib.endDrawing()
  }

  func makeBoxes(_ count: Int, borderDistance: Float) {
    for _ in 0..<count {
      let box: FlixBox = FlixBox(
        pos: Vector3(x: .random(in: -borderDistance...borderDistance), y: .random(in: -borderDistance...borderDistance), z: 0),
        size: Vector3(x: Float.random(in: 0.1...0.7), y: Float.random(in: 0.1...0.7), z: Float.random(in: 0.1...0.7)),
        // size: Vector3(0.2), // debug
        color: Color.brown,
        isStatic: false, useStaticModel: true)
      box.rotation = .euler(Float.random(in: 0..<360), Float.random(in: 0..<360), Float.random(in: 0..<360), .degrees)
      box.rigidbody!.angularVelocity = PHYVector3(Float.random(in: -2..<2), Float.random(in: -2..<2), Float.random(in: -2..<2))
      box.rigidbody!.linearVelocity = PHYVector3(Float.random(in: -2..<2), Float.random(in: -2..<2), 0)
    }
  }

  func makeWalls(borderDistance: Float) {
    let wallWidth: Float = 200.0
    _ = FlixBox(
      pos: Vector3(x: -borderDistance - wallWidth * 2, y: 0, z: 0),
      size: Vector3(x: wallWidth, y: 10000, z: 0.2),
      color: .rayWhite,
      isStatic: true,
      flixType: .wall
    )
    _ = FlixBox(
      pos: Vector3(x: borderDistance + wallWidth * 2, y: 0, z: 0),
      size: Vector3(x: wallWidth, y: 10000, z: 0.2),
      color: .rayWhite,
      isStatic: true,
      flixType: .wall)
    _ = FlixBox(
      pos: Vector3(x: 0, y: borderDistance + wallWidth * 2, z: 0),
      size: Vector3(x: 10000, y: wallWidth, z: 0.2),
      color: .rayWhite,
      isStatic: true,
      flixType: .wall)
    _ = FlixBox(
      pos: Vector3(x: 0, y: -borderDistance - wallWidth * 2, z: 0),
      size: Vector3(x: 10000, y: wallWidth, z: 0.2),
      color: .rayWhite,
      isStatic: true,
      flixType: .wall)
  }
}
