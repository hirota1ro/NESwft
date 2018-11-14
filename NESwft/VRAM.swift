//
//  VRAM.swift
//  NESwft
//
//  Created by HIROTA Ichiro on 2018/11/10.
//  Copyright © 2018 HIROTA Ichiro. All rights reserved.
//

import Foundation

//      (0,0)     (256,0)     (511,0)
//        +-----------+-----------+
//        |           |           |
//        |           |           |
//        |   $2000   |   $2400   |
//        |           |           |
//        |           |           |
// (0,240)+-----------+-----------+(511,240)
//        |           |           |
//        |           |           |
//        |   $2800   |   $2C00   |
//        |           |           |
//        |           |           |
//        +-----------+-----------+
//      (0,479)   (256,479)   (511,479)

// Area number
// +---+---+
// | 0 | 1 |
// +---+---+
// | 2 | 3 |
// +---+---+
@inlinable func area(_ addr: UInt16) -> UInt16 { return (addr >> 10) & 3 }

// Nametable Mirroring

// Horizontal Mirroring
// +---+---+
// | A | A'|
// +---+---+
// | B | B'|
// +---+---+
class BGHM: Memory {
    let a = Nametable()
    let b = Nametable()

    subscript(addr: UInt16) -> UInt8 {
        get {
            assert(0x2000 <= addr && addr < 0x3000)
            switch area(addr) {
            case 0, 1:
                return a[addr & 0x3FF]
            case 2, 3:
                return b[addr & 0x3FF]
            default:
                break
            }
            return 0
        }
        set {
            assert(0x2000 <= addr && addr < 0x3000)
            switch area(addr) {
            case 0, 1:
                a[addr & 0x3FF] = newValue
            case 2, 3:
                b[addr & 0x3FF] = newValue
            default:
                break
            }
        }
    }
}

extension BGHM: CustomStringConvertible {
    var description: String {
        return "Horizontal Mirroring\n-- Nametable($2000, $2400) --\n\(a)\n-- Nametable($2800, $2C00) --\n\(b)"
    }
}

// Vertical Mirroring
// +---+---+
// | A | B |
// +---+---+
// | A'| B'|
// +---+---+
class BGVM: Memory {
    let a = Nametable()
    let b = Nametable()

    subscript(addr: UInt16) -> UInt8 {
        get {
            assert(0x2000 <= addr && addr < 0x3000)
            switch area(addr) {
            case 0, 2:
                return a[addr & 0x3FF]
            case 1, 3:
                return b[addr & 0x3FF]
            default:
                break
            }
            return 0
        }
        set {
            assert(0x2000 <= addr && addr < 0x3000)
            switch area(addr) {
            case 0, 2:
                a[addr & 0x3FF] = newValue
            case 1, 3:
                b[addr & 0x3FF] = newValue
            default:
                break
            }
        }
    }
}

extension BGVM: CustomStringConvertible {
    var description: String {
        return "Vertical Mirroring\n-- Nametable($2000, $2800) --\n\(a)\n-- Nametable($2400, $2C00) --\n\(b)"
    }
}

// 4-Screen
// +---+---+
// | A | B |
// +---+---+
// | C | D |
// +---+---+
class BG4: Memory {
    let a = Nametable()
    let b = Nametable()
    let c = Nametable()
    let d = Nametable()

    subscript(addr: UInt16) -> UInt8 {
        get {
            assert(0x2000 <= addr && addr < 0x3000)
            switch area(addr) {
            case 0:
                return a[addr & 0x3FF]
            case 1:
                return b[addr & 0x3FF]
            case 2:
                return c[addr & 0x3FF]
            case 3:
                return d[addr & 0x3FF]
            default:
                break
            }
            return 0
        }
        set {
            assert(0x2000 <= addr && addr < 0x3000)
            switch area(addr) {
            case 0:
                a[addr & 0x3FF] = newValue
            case 1:
                b[addr & 0x3FF] = newValue
            case 2:
                c[addr & 0x3FF] = newValue
            case 3:
                d[addr & 0x3FF] = newValue
            default:
                break
            }
        }
    }
}

extension BG4: CustomStringConvertible {
    var description: String {
        return "4 Screen\n-- Nametable($2000) --\n\(a)\n-- Nametable($2400) --\n\(b)\n-- Nametable($2800) --\n\(c)\n-- Nametable($2C00) --\n\(d)"
    }
}

class Nametable {
    var data: Data = Data(count: 0x400)
}

extension Nametable: Memory {
    /**
     * @param addr (0x0000...0x03FF)
     */
    subscript(addr: UInt16) -> UInt8 {
        get { return data[Int(addr)] }
        set { data[Int(addr)] = newValue }
    }
}

extension Nametable {
    var nameTable: [[UInt8]] {
        var a: [[UInt8]] = []
        for ty in 0 ..< 30 {
            var b: [UInt8] = []
            for tx in 0 ..< 32 {
                b.append(data[ty * 32 + tx])
            }
            a.append(b)
        }
        return a
    }
    var attrTable: [[UInt8]] {
        var a: [[UInt8]] = []
        for ty in 0 ..< 30 {
            var b: [UInt8] = []
            for tx in 0 ..< 32 {
                let aaaa = (ty / 4) * 8 + tx / 4 + 0x03C0
                let dd = data[aaaa]
                let l = (tx % 4) / 2
                let h = (ty % 4) / 2
                let bits = (h * 2 + l) * 2
                let n = (dd >> bits) & 3
                b.append(n)
            }
            a.append(b)
        }
        return a
    }
}

extension Nametable: CustomStringConvertible {
    var description: String {
        let ntbl = nameTable.map({ x in x.map({ $0.hex }).joined(separator: " ") }).joined(separator: "\n")
        let atbl = attrTable.map({ x in x.map({ $0.hex }).joined(separator: " ") }).joined(separator: "\n")
        return "--Name Table--\n\(ntbl)\n--Attribute Table--\n\(atbl)"
    }
}
