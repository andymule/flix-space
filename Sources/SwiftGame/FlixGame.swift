import PhyKit
import Raylib
import RaylibC
import simd

// GLSL 4.1

class FlixGame {
    static let physicsWorld: PHYWorld = PHYWorld()
    static var rigidbodyToFlixObject: [PHYRigidBody: FlixObject] = .init()  // used to trace back collisions to objects
    static var drawList3D: [FlixObject] = .init()
	static var drawList2D: [FlixObject] = .init()
    static var planetList: [FlixPlanet] = .init()
    static var inputList: [FlixInput] = .init()

    static var itemID: Int = 0  // used to assign unique IDs to objects
    static var deltaTime: Float = 0
    static var time: Double = 0
    static let screenWidth: Int32 = 1400
    static let screenHeight: Int32 = 800
    static let aspectRatio: Float = Float(screenWidth) / Float(screenHeight)
    let HUD: FlixHUD

    var ship: FlixShip
    static let cameras: FlixCamera = FlixCamera()
    private var collisionDelegate: CollisionDelegate = CollisionDelegate()

    public init() {
        Raylib.setConfigFlags(.msaa4xHint | .vsyncHint)
        Raylib.setTraceLogLevel(.warning)
        Raylib.initWindow(Self.screenWidth, Self.screenHeight, "FlixGame")
        Raylib.setTargetFPS(120)

        FlixGame.physicsWorld.gravity = PHYVector3(x: 0, y: 0, z: 0)  // y = -9.8

        ship = FlixShip(
            pos: Vector3(x: 0, y: 0, z: 0),
            scale: 0.3,
            color: .white,
            isStatic: false)
        HUD = FlixHUD(ship: ship)
       let borderDistance: Float = 30.0
        makeWalls(borderDistance: borderDistance)
        makePlanet(radius: 13, pos: Vector3(x: 18, y: 18, z: 0))
        makeBoxes(750, borderDistance: borderDistance)
    }

    public func run() {
        FlixGame.physicsWorld.collisionDelegate = collisionDelegate
        FlixGame.physicsWorld.triggerDelegate = collisionDelegate
        FlixGame.physicsWorld.simulationDelegate = collisionDelegate

        while Raylib.windowShouldClose == false {
            ship.isInfluencedCurrently = false
            FlixGame.inputList.forEach { $0.handleInput() }
            FlixGame.deltaTime = Raylib.getFrameTime()
            FlixGame.time = Raylib.getTime()
            FlixGame.physicsWorld.simulationTime = FlixGame.time
            Self.cameras.update(ship: ship)
            draw()
        }
        Raylib.closeWindow()
    }

    func draw() {
        Raylib.beginDrawing()
        Raylib.clearBackground(.black)
        Raylib.beginMode3D(Self.cameras.camera3D)
        FlixGame.drawList3D.forEach { $0.handleDraw() }
        Raylib.endMode3D()
        Raylib.drawFPS(10, Self.screenHeight - 30)
        HUD.draw()
        Raylib.beginMode2D(Self.cameras.camera2D)
        Self.planetList.forEach({ $0.handleDraw2D() })
        Raylib.endMode2D()
        Raylib.endDrawing()
    }

    func makePlanet(radius: Float, pos: Vector3) {
        let planet: FlixPlanet = FlixPlanet(
            position: pos,
            radius: radius,
            color: .rayWhite,
            // isStatic: true,
            flixType: .planet)
        planet.rigidbody!.angularVelocity = PHYVector3(0, 0, 1)
        Self.planetList.append(planet)
    }

    func makeBoxes(_ count: Int, borderDistance: Float) {
        for _ in 0..<count {
            var box: FlixBox = FlixBox(
                pos: Vector3(
                    x: .random(in: -borderDistance...borderDistance), y: .random(in: -borderDistance...borderDistance), z: 0),
                size: Vector3(x: Float.random(in: 0.1...0.8), y: Float.random(in: 0.1...0.8), z: Float.random(in: 0.1...0.8)),
                color: Color.brown,
                isStatic: false, autoInsertIntoList: false, useStaticModel: true)
            for p: FlixPlanet in Self.planetList {
                while box.position.distance(p.position) < p.radius + max(box.size.x, box.size.y, box.size.z) {
                    box = FlixBox(
                        pos: Vector3(
                            x: .random(in: -borderDistance...borderDistance), y: .random(in: -borderDistance...borderDistance),
                            z: 0),
                        size: Vector3(
                            x: Float.random(in: 0.1...0.7), y: Float.random(in: 0.1...0.7), z: Float.random(in: 0.1...0.7)),
                        color: Color.brown,
                        isStatic: false, autoInsertIntoList: false, useStaticModel: true)
                }
            }
            box.rotation = .euler(Float.random(in: 0..<360), Float.random(in: 0..<360), Float.random(in: 0..<360), .degrees)
            box.rigidbody!.angularVelocity = PHYVector3(
                Float.random(in: -2..<2), Float.random(in: -2..<2), Float.random(in: -2..<2))
            box.rigidbody!.linearVelocity = PHYVector3(Float.random(in: -2..<2), Float.random(in: -2..<2), 0)
            box.insertIntoDrawList()
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
