import PhyKit
import Raylib
import RaylibC
import simd

class FlixGame {
    static let physicsWorld: PHYWorld = PHYWorld()
    static var rigidbodyToFlixObject: [PHYRigidBody: FlixObject] = .init()
    static var drawList3D: [FlixObject] = .init()
    static var drawList2D: [FlixObject] = .init()
    static var planetList: [FlixPlanet] = .init()
    static var inputList: [FlixInput] = .init()

    static var itemID: Int = 0
    static var deltaTime: Float = 0
    static var time: Double = 0
    static let screenWidth: Int32 = 1400
    static let screenHeight: Int32 = 800
    static let aspectRatio: Float = Float(screenWidth) / Float(screenHeight)

    private static let boxCount = 750
    private static let borderDistance: Float = 30.0
    private static let wallWidth: Float = 200.0
    static let gravityForceScale: Float = 6.0
    private static let targetFPS: Int32 = 120

    let HUD: FlixHUD
    var ship: FlixShip
    static let cameras: FlixCamera = FlixCamera()
    private var collisionDelegate: CollisionDelegate = CollisionDelegate()

    public init() {
        Raylib.setConfigFlags(.msaa4xHint | .vsyncHint)
        Raylib.setTraceLogLevel(.warning)
        Raylib.initWindow(Self.screenWidth, Self.screenHeight, "FlixGame")
        Raylib.setTargetFPS(Self.targetFPS)

        FlixGame.physicsWorld.gravity = PHYVector3(x: 0, y: 0, z: 0)

        ship = FlixShip(
            pos: Vector3(x: 0, y: 0, z: 0),
            scale: 0.3,
            color: .white,
            isStatic: false)
        HUD = FlixHUD(ship: ship)
        makeWalls(borderDistance: Self.borderDistance)
        makePlanet(radius: 13, pos: Vector3(x: 18, y: 18, z: 0))
        makeBoxes(Self.boxCount, borderDistance: Self.borderDistance)

        FlixGame.physicsWorld.collisionDelegate = collisionDelegate
        FlixGame.physicsWorld.triggerDelegate = collisionDelegate
        FlixGame.physicsWorld.simulationDelegate = collisionDelegate
    }

    public func run() {
        while Raylib.windowShouldClose == false {
            ship.isInfluencedCurrently = false
            for input in FlixGame.inputList { input.handleInput() }
            FlixGame.deltaTime = Raylib.getFrameTime()
            FlixGame.time = Raylib.getTime()
            FlixGame.physicsWorld.simulationTime = FlixGame.time
            for obj in FlixGame.drawList3D { obj.update(dt: FlixGame.deltaTime) }
            Self.cameras.update(ship: ship)
            draw()
        }
        Raylib.closeWindow()
    }

    func draw() {
        Raylib.beginDrawing()
        Raylib.clearBackground(.black)
        Raylib.beginMode3D(Self.cameras.camera3D)
        for obj in FlixGame.drawList3D { obj.handleDraw() }
        Raylib.endMode3D()
        Raylib.drawFPS(10, Self.screenHeight - 30)
        HUD.draw()
        Raylib.beginMode2D(Self.cameras.camera2D)
        for planet in Self.planetList { planet.handleDraw2D() }
        Raylib.endMode2D()
        Raylib.endDrawing()
    }

    func makePlanet(radius: Float, pos: Vector3) {
        let planet = FlixPlanet(
            position: pos,
            radius: radius,
            color: .rayWhite,
            flixType: .planet)
        planet.rigidbody.angularVelocity = PHYVector3(0, 0, 1)
        Self.planetList.append(planet)
    }

    private func randomValidPosition(borderDistance: Float, minClearance: Float) -> Vector3 {
        var pos: Vector3
        var attempts = 0
        let maxAttempts = 1000
        repeat {
            pos = Vector3(
                x: .random(in: -borderDistance...borderDistance),
                y: .random(in: -borderDistance...borderDistance), z: 0)
            attempts += 1
            if attempts >= maxAttempts { break }
        } while Self.planetList.contains(where: { pos.distance($0.position) < $0.radius + minClearance })
        return pos
    }

    func makeBoxes(_ count: Int, borderDistance: Float) {
        for _ in 0..<count {
            let size = Vector3(
                x: Float.random(in: 0.1...0.8),
                y: Float.random(in: 0.1...0.8),
                z: Float.random(in: 0.1...0.8))
            let pos = randomValidPosition(
                borderDistance: borderDistance,
                minClearance: max(size.x, size.y, size.z))
            let box = FlixBox(
                pos: pos, size: size, color: Color.brown,
                isStatic: false, autoInsertIntoList: false, useStaticModel: true)
            box.rotation = .euler(Float.random(in: 0..<360), Float.random(in: 0..<360), Float.random(in: 0..<360), .degrees)
            box.rigidbody.angularVelocity = PHYVector3(
                Float.random(in: -2..<2), Float.random(in: -2..<2), Float.random(in: -2..<2))
            box.rigidbody.linearVelocity = PHYVector3(Float.random(in: -2..<2), Float.random(in: -2..<2), 0)
            box.insertIntoDrawList()
        }
    }

    func makeWalls(borderDistance: Float) {
        let w = Self.wallWidth
        _ = FlixBox(
            pos: Vector3(x: -borderDistance - w * 2, y: 0, z: 0),
            size: Vector3(x: w, y: 10000, z: 0.2),
            color: .rayWhite, isStatic: true, flixType: .wall)
        _ = FlixBox(
            pos: Vector3(x: borderDistance + w * 2, y: 0, z: 0),
            size: Vector3(x: w, y: 10000, z: 0.2),
            color: .rayWhite, isStatic: true, flixType: .wall)
        _ = FlixBox(
            pos: Vector3(x: 0, y: borderDistance + w * 2, z: 0),
            size: Vector3(x: 10000, y: w, z: 0.2),
            color: .rayWhite, isStatic: true, flixType: .wall)
        _ = FlixBox(
            pos: Vector3(x: 0, y: -borderDistance - w * 2, z: 0),
            size: Vector3(x: 10000, y: w, z: 0.2),
            color: .rayWhite, isStatic: true, flixType: .wall)
    }
}
