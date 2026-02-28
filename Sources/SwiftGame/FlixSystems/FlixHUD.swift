import PhyKit
import Raylib
import RaylibC
import simd

class FlixHUD {
    let myShip: FlixShip
    let font: Font = LoadFont("")

    init(ship: FlixShip) {
        myShip = ship
    }

    func draw() {
        let orientationText = "oSN: \((myShip.rigidbody.eulerOrientation.z.rad2deg * 10.0).rounded() / 10.0)"
        let angularSpeedText = "a/s: \((myShip.rigidbody.angularVelocity.vector3.z * 10.0).rounded() / 10.0)"
        let speedVec = myShip.rigidbody.linearVelocity.vector3.roundedTenths
        let speedText = "S/s: \(speedVec.x), \(speedVec.y), \(speedVec.z)"
        let positionVec = myShip.rigidbody.position.vector3.roundedTenths
        let positionText = "Pos: \(positionVec.x), \(positionVec.y), \(positionVec.z)"
        let gravityText = "inG: \(myShip.isInfluencedCurrently ? "Yes" : "No")"

        DrawTextEx(font, orientationText, .init(x: 10, y: 10), 20, 1, .rayWhite)
        DrawTextEx(font, angularSpeedText, .init(x: 10, y: 30), 20, 1, .rayWhite)
        DrawTextEx(font, speedText, .init(x: 10, y: 50), 20, 1, .rayWhite)
        DrawTextEx(font, positionText, .init(x: 10, y: 70), 20, 1, .rayWhite)
        DrawTextEx(font, gravityText, .init(x: 10, y: 90), 20, 1, myShip.isInfluencedCurrently ? .green : .red)
    }
}
