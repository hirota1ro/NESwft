//
//  Pad.swift
//  NESwft
//
//  Created by HIROTA Ichiro on 2018/10/29.
//  Copyright © 2018 HIROTA Ichiro. All rights reserved.
//

import Foundation

// Standard controller
class Pad: Memory {

    var con1 = Controller()
    var con2 = Controller()

    struct Controller {
        // 7  bit  0
        // ---- ----
        // RLDU SsBA
        // |||| |||+- A
        // |||| ||+-- B
        // |||| |+--- Select
        // |||| +---- Start
        // |||+------ Up
        // ||+------- Down
        // |+-------- Left
        // +--------- Right
        var rawValue: UInt8 = 0

        // Button status for each controller is returned as an 8-bit
        // report in the following order:
        // A, B, Select, Start, Up, Down, Left, Right.
        var index: Int = 0
    }

    // Controller port registers
    static let CON1: UInt16 = 0x4016 // RW
    static let CON2: UInt16 = 0x4017 // R-

    subscript(addr: UInt16) -> UInt8 {
        get {
            switch addr {
            case Pad.CON1:
                return port1
            case Pad.CON2:
                return port2
            default:
                fatalError("SEGV(\(addr.hex))")
            }
        }
        set {
            switch addr {
            case Pad.CON1:
                port1 = newValue
            case Pad.CON2:
                break // read only
            default:
                fatalError("SEGV(\(addr.hex))←\(newValue.hex)")
            }
        }
    }

    var port1: UInt8 {
        get { return con1.port }
        set { strobe = newValue[bit: 0].bool }
    }

    var port2: UInt8 {
        get { return con2.port }
    }

    var strobe: Bool = false {
        didSet {
            if oldValue && !strobe { // 1→0
                con1.index = 0
                con2.index = 0
            }
        }
    }
}

extension Pad.Controller {
    subscript(i: Int) -> UInt8 { return rawValue[bit: i] }

    var port: UInt8 {
        mutating get {
            defer { index += 1 }
            return self[index & 0b0000_0111]
        }
    }
}

extension Pad.Controller {
    var a: Bool {
        get { return rawValue[bit: 0].bool }
        set { rawValue[bit: 0] = newValue.byte }
    }
    var b: Bool {
        get { return rawValue[bit: 1].bool }
        set { rawValue[bit: 1] = newValue.byte }
    }
    var select: Bool {
        get { return rawValue[bit: 2].bool }
        set { rawValue[bit: 2] = newValue.byte }
    }
    var start: Bool {
        get { return rawValue[bit: 3].bool }
        set { rawValue[bit: 3] = newValue.byte }
    }
    var up: Bool {
        get { return rawValue[bit: 4].bool }
        set { rawValue[bit: 4] = newValue.byte }
    }
    var down: Bool {
        get { return rawValue[bit: 5].bool }
        set { rawValue[bit: 5] = newValue.byte }
    }
    var left: Bool {
        get { return rawValue[bit: 6].bool }
        set { rawValue[bit: 6] = newValue.byte }
    }
    var right: Bool {
        get { return rawValue[bit: 7].bool }
        set { rawValue[bit: 7] = newValue.byte }
    }
}

extension Pad.Controller: CustomStringConvertible {
    var description: String {
        let r = self.rawValue
        let a: [String] = ["R", "L", "D", "U", "S", "s", "B", "A"]
        let b = a.enumerated().map { (i,s) in r[bit: 7-i].bool ? s : "_" }
        return b.joined(separator: "")
    }
}
