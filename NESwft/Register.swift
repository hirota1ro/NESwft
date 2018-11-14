//
//  Register.swift
//  NESwft
//
//  Created by HIROTA Ichiro on 2018/10/25.
//  Copyright © 2018 HIROTA Ichiro. All rights reserved.
//

import Foundation

// CPU Register
struct Register {
    var a: UInt8
    var x: UInt8
    var y: UInt8
    var s: UInt8
    var p: P
    var pc: UInt16
}

extension Register: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(a)
        hasher.combine(x)
        hasher.combine(y)
        hasher.combine(s)
        hasher.combine(p)
        hasher.combine(pc)
    }
}

extension Register: CustomStringConvertible {
    var description: String {
        return "A=\(a.hex) X=\(x.hex) Y=\(y.hex) S=\(s.hex) P=\(p) PC=\(pc.hex)"
    }
}

// Processor Status Register
extension Register {
    struct P {
        var n: Bool
        var v: Bool
        var r: Bool
        var b: Bool
        var d: Bool
        var i: Bool
        var z: Bool
        var c: Bool
    }
}

extension Register.P {

    init(rawValue: UInt8) {
        self.init(n: rawValue[bit: 7].bool,
                  v: rawValue[bit: 6].bool,
                  r: rawValue[bit: 5].bool,
                  b: rawValue[bit: 4].bool,
                  d: rawValue[bit: 3].bool,
                  i: rawValue[bit: 2].bool,
                  z: rawValue[bit: 1].bool,
                  c: rawValue[bit: 0].bool)
    }

    var rawValue: UInt8 {
        get {
            return (n.byte << 7)
              | (v.byte << 6)
              | (r.byte << 5)
              | (b.byte << 4)
              | (d.byte << 3)
              | (i.byte << 2)
              | (z.byte << 1)
              | (c.byte << 0)
        }
        set {
            n = newValue[bit: 7].bool
            v = newValue[bit: 6].bool
            r = newValue[bit: 5].bool
            b = newValue[bit: 4].bool
            d = newValue[bit: 3].bool
            i = newValue[bit: 2].bool
            z = newValue[bit: 1].bool
            c = newValue[bit: 0].bool
        }
    }
}

extension Register.P: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

extension Register.P: CustomStringConvertible {
    var description: String {
        let r = self.rawValue
        let a: [String] = ["N", "V", "R", "B", "D", "I", "Z", "C"]
        let b = a.enumerated().map { (i,s) in r[bit: 7-i].bool ? s : "_" }
        return b.joined(separator: "")
    }
}
