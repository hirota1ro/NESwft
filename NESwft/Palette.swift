//
//  Palette.swift
//  NESwft
//
//  Created by HIROTA Ichiro on 2018/11/10.
//  Copyright © 2018 HIROTA Ichiro. All rights reserved.
//

import Foundation

struct Palette {
    let palmem: PalMem
    let addr: UInt16

    /**
     * @param index color index in palette (0...3)
     * @return color ID (0x00 ... 0x3F)
     */
    subscript(index: UInt8) -> UInt8 {
        return palmem[cooked: addr + UInt16(index)]
    }
}

extension Palette {
    var colors: [UInt8] {
        var a: [UInt8] = []
        for i: UInt8 in 0 ..< 4 {
            a.append(self[i])
        }
        return a
    }
}

extension Palette: CustomStringConvertible {
    var description: String {
        let s = colors.map({ $0.hex }).joined(separator: ", ")
        return "[\(s)]"
    }
}

class PalMem: Memory {
    var data = Data(bytes: [0x09,0x01,0x00,0x01, 0x00,0x02,0x02,0x0D, 0x08,0x10,0x08,0x24, 0x00,0x00,0x04,0x2C,
                            0x09,0x01,0x34,0x03, 0x00,0x04,0x00,0x14, 0x08,0x3A,0x00,0x02, 0x00,0x20,0x2C,0x08])

    /**
     * @param addr (0x3F00...0x3F1F)
     * @return color ID (0x00 ... 0x3F)
     */
    subscript(addr: UInt16) -> UInt8 {
        get {
            assert(0x3F00 <= addr && addr < 0x3F20)
            return data[Int(addr & 0x001F)] & 0b0011_1111
        }
        set {
            assert(0x3F00 <= addr && addr < 0x3F20)
            data[Int(addr & 0x001F)] = newValue
        }
    }

    /** Addresses $3F10/$3F14/$3F18/$3F1C are mirrors of $3F00/$3F04/$3F08/$3F0C.
     * @param addr (0x3F00...0x3F1F)
     * @return color ID (0x00 ... 0x3F)
     */
    subscript(mirror addr: UInt16) -> UInt8 {
        get {
            if (addr & 0x0013) == 0x10 { // 0x3F10, 0x3F14, 0x3F18, 0x3F1C
                return self[addr & 0xFFEF]
            } else {
                return self[addr]
            }
        }
        set {
            if (addr & 0x0013) == 0x10 { // 0x3F10, 0x3F14, 0x3F18, 0x3F1C
                self[addr & 0xFFEF] = newValue
            } else {
                self[addr] = newValue
            }
        }
    }

    /**
     * @param addr (0x3F00...0x3F1F)
     * @return color ID (0x00 ... 0x3F)
     */
    subscript(cooked addr: UInt16) -> UInt8 {
        if (addr & 3) == 0 { // 0x3F00, 0x3F04, 0x3F08, 0x3F0C, 0x3F10, 0x3F14, 0x3F18, 0x3F1C
            return self[0x3F00]
        } else {
            return self[addr]
        }
    }
}

extension PalMem {
    /**
     * @param number (0..<4) 
     * @param base BG=0x3F00, SP=0x3F10
     */
    func palettes(base: UInt16) -> [Palette] {
        var a: [Palette] = []
        for i: UInt16 in 0 ..< 4 {
            a.append(Palette(palmem: self, addr: base + i * 4))
        }
        return a
    }
}

extension PalMem: CustomStringConvertible {
    var description: String {
        let addrs: [UInt16] = [0x3F00, 0x3F10]
        return addrs.map( { addr in
            let s = palettes(base: addr).map({ $0.description }).joined(separator: ", ")
            return "\(addr.hex): \(s)"
        }).joined(separator: "\n")
    }
}
