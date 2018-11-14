//
//  Memory.swift
//  NESwft
//
//  Created by HIROTA Ichiro on 2018/10/23.
//  Copyright © 2018 HIROTA Ichiro. All rights reserved.
//

import Foundation

protocol Memory: AnyObject {
    subscript(addr: UInt16) -> UInt8 { get set }
}

extension Memory {
    subscript(word addr: UInt16) -> UInt16 {
        get {
            let lo = self[addr]
            let hi = self[addr &+ 1]
            return UInt16(lo: lo, hi: hi)
        }
        set {
            self[addr] = newValue.lo
            self[addr &+ 1] = newValue.hi
        }
    }
}

extension Memory {
    subscript(pagebound addr: UInt16) -> UInt16 {
        get {
            let lo = self[addr]
            let hi = self[UInt16(lo: addr.lo &+ 1, hi: addr.hi)]
            return UInt16(lo: lo, hi: hi)
        }
        set {
            self[addr] = newValue.lo
            self[UInt16(lo: addr.lo &+ 1, hi: addr.hi)] = newValue.hi
        }
    }
}


// RAM on Data
class DRAM: Memory {
    var data: Data
    init(data: Data) { self.data = data }

    subscript(addr: UInt16) -> UInt8 {
        get { return data[Int(addr)] }
        set { data[Int(addr)] = newValue }
    }

    func subdata(in range: Range<Data.Index>) -> Data {
        return data.subdata(in: range)
    }
}

extension DRAM: CustomStringConvertible {
    var description: String {
        return data.hexDump()
    }
}

// Work RAM
class WRAM: Memory {
    var data = Data(count: 0x0800)

    subscript(addr: UInt16) -> UInt8 {
        get { return data[Int(addr & 0x07FF)] }
        set { data[Int(addr & 0x07FF)] = newValue }
    }
}

extension WRAM: CustomStringConvertible {
    var description: String {
        return data.hexDump()
    }
}


// CPU BUS
class BUS {

    let ram: Memory
    let ppu: Memory
    let pad: Memory
    let apu: Memory
    let mapper: Memory

    init(ram: Memory, ppu: Memory, pad: Memory, apu: Memory, mapper: Memory) {
        self.ram = ram
        self.ppu = ppu
        self.pad = pad
        self.apu = apu
        self.mapper = mapper
    }
}

extension BUS: Memory {

    subscript(addr: UInt16) -> UInt8 {
        get {
            switch addr >> 12 {
            case 0, 1: // 0x0000 ... 0x1FFF
                return ram[addr]
            case 2, 3: // 0x2000 ... 0x3FFF
                return ppu[addr & 0x2007]
            case 4:    // 0x4000 ... 0x4FFF
                if addr < 0x4020 {
                    switch addr {
                    case Pad.CON1, Pad.CON2:
                        return pad[addr]
                    default:
                        return apu[addr]
                    }
                } else {
                    return mapper[addr]
                }
            default:   // 0x5000 ... 0xFFFF
                return mapper[addr]
            }
        }
        set {
            switch addr >> 12 {
            case 0, 1: // 0x0000 ... 0x1FFF
                ram[addr] = newValue
            case 2, 3: // 0x2000 ... 0x3FFF
                ppu[addr & 0x2007] = newValue
            case 4:    // 0x4000 ... 0x4FFF
                if addr < 0x4020 {
                    switch addr {
                    case Pad.CON1, Pad.CON2:
                        pad[addr] = newValue
                    default:
                        apu[addr] = newValue
                    }
                } else {
                    mapper[addr] = newValue
                }
            default:   // 0x5000 ... 0xFFFF
                mapper[addr] = newValue
            }
        }
    }
}

// Direct Memory Access
class DMA {

    let src: Memory
    let ppu: Memory
    let dst: Memory

    init(src: Memory, ppu: Memory, dst: Memory) {
        self.src = src
        self.ppu = ppu
        self.dst = dst
    }

    var value: UInt8 = 0 {
        didSet {
            let from = UInt16(lo: 0, hi: value)
            let tt = ppu[PPU.Reg.OAMADDR.rawValue] // $2003
            let to = UInt16(tt)
            for i: UInt16 in 0 ..< 256 {
                dst[(to + i) & 0xFF] = src[from + i]
            }
            clocks = 514
        }
    }

    var clocks: Int = 0
}

extension DMA: Memory {
    static let OAMDMA: UInt16 = 0x4014

    subscript(addr: UInt16) -> UInt8 {
        get {
            if addr == DMA.OAMDMA {
                return value
            } else {
                return src[addr]
            }
        }
        set {
            if addr == DMA.OAMDMA {
                value = newValue
            } else {
                src[addr] = newValue
            }
        }
    }
}
