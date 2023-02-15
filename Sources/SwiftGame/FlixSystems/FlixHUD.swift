import PhyKit
import Raylib
import RaylibC
import simd

class FlixHUD {
  let myShip: FlixShip
  let font: Font = LoadFont("Arial.ttf")

  init(ship: FlixShip) {
    myShip = ship
  }

  func draw() {
    // DrawTextPro(font, "Test", Vector2(x: 100, y: 100), Vector2(x: 100, y: 100), 0, 20, 20/10, .rayWhite)
    DrawText("oSN: \((myShip.rigidbody!.eulerOrientation.z.rad2deg*Float(10.0)).rounded()/10.0)", 10, 10, 20, .rayWhite)
    DrawText("a/s: \((myShip.rigidbody!.angularVelocity.vector3.z*Float(10.0)).rounded()/10.0)", 10, 30, 20, .rayWhite)
    DrawText("S/s: \(myShip.rigidbody!.linearVelocity.vector3.roundedTenths)", 10, 50, 20, .rayWhite)
    DrawText("Ups: \(myShip.rigidbody!.position.vector3.roundedTenths)", 10, 70, 20, .rayWhite)
    DrawText("inG: \(myShip.isInfluencedCurrently ? "Yes" : "No")", 10, 90, 20, myShip.isInfluencedCurrently ? .green : .red)
    // Raylib.drawTextPro(font: Font, text: String, position: Vector2, origin: Vector2, rotation: Float, fontSize: Float, spacing: Float, tint: Color)
  }
}
