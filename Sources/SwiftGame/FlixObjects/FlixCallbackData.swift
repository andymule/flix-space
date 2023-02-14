import PhyKit
import Raylib
import RaylibC
import simd

public class FlixCallBackData {
  let cb_ints: [Int?]
  let cb_floats: [Float?]
  let cb_flixObjs: [FlixObject?]
  init(ints: [Int?] = .init(), floats: [Float?] = .init(), flixObjs: [FlixObject?] = .init()) {
    cb_ints = ints
    cb_floats = floats
    cb_flixObjs = flixObjs
  }
}
