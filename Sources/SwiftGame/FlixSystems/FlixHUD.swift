import PhyKit
import Raylib
import RaylibC
import simd

class FlixHUD {
  let myShip: FlixShip

  //whoops fail on purpose to use default font for now // LoadFont(Bundle.module.path(forResource: "meslo", ofType: "ttf")!)
  let font: Font = LoadFont("") 

  init(ship: FlixShip) {
    // Raylib.guiSetFont(font)
    myShip = ship
  }

  func draw() {
    // DrawTextPro(font, "Test", Vector2(x: 100, y: 100), Vector2(x: 100, y: 100), 0, 20, 20/10, .rayWhite)
    let osn = "oSN: \((myShip.rigidbody!.eulerOrientation.z.rad2deg*Float(10.0)).rounded()/10.0)"
    let ass = "a/s: \((myShip.rigidbody!.angularVelocity.vector3.z*Float(10.0)).rounded()/10.0)"
    let ssT = myShip.rigidbody!.linearVelocity.vector3.roundedTenths  
    let ss = "S/s: \(ssT.x), \(ssT.y), \(ssT.z)"
    let upsT = myShip.rigidbody!.position.vector3.roundedTenths
    let ups = "Ups: \(upsT.x), \(upsT.y), \(upsT.z)"
    let ing = "inG: \(myShip.isInfluencedCurrently ? "Yes" : "No")"

    DrawTextEx(font, osn, .init(x: 10, y: 10), 20, 1, .rayWhite)
    DrawTextEx(font, ass, .init(x: 10, y: 30), 20, 1, .rayWhite)
    DrawTextEx(font, ss, .init(x: 10, y: 50), 20, 1, .rayWhite)
    DrawTextEx(font, ups, .init(x: 10, y: 70), 20, 1, .rayWhite)
    DrawTextEx(font, ing, .init(x: 10, y: 90), 20, 1, myShip.isInfluencedCurrently ? .green : .red)
    // Raylib.drawTextPro(font: Font, text: String, position: Vector2, origin: Vector2, rotation: Float, fontSize: Float, spacing: Float, tint: Color)
  }
}
