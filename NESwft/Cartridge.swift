//
//  Cartridge.swift
//  NESwft
//
//  Created by HIROTA Ichiro on 2018/10/24.
//  Copyright © 2018 HIROTA Ichiro. All rights reserved.
//

import Foundation

struct Cartridge {
    let header: Header
    let prgROM: Data
    let chrROM: Data
}

extension Cartridge {
    struct Header {
        let isValid: Bool
        let chrROMSize: Int
        let prgROMSize: Int
        let mapper: UInt8
        let prgRAMSize: Int
        let flags6: Flags6
        let flags7: Flags7
        let flags9: Flags9
        let flags10: Flags10
    }
}

extension Cartridge.Header {
    // (16 bytes)
    // [byte 0-3] Constant $4E $45 $53 $1A ("NES" followed by MS-DOS end-of-file)
    // [byte 4] Size of PRG ROM in 16 KB units
    // [byte 5] Size of CHR ROM in 8 KB units (Value 0 means the board uses CHR RAM)
    // [byte 6] Flags 6
    // [byte 7] Flags 7
    // [byte 8] Size of PRG RAM in 8 KB units (Value 0 infers 8 KB for compatibility; see PRG RAM circuit)
    // [byte 9] Flags 9
    // [byte 10] Flags 10 (unofficial)
    // [byte 11-15] Zero filled
    init(data: Data) {
        isValid = data.subdata(in: 0..<4) == Data([0x4E, 0x45, 0x53, 0x1A])
        prgROMSize = Int(data[4]) * 0x4000
        chrROMSize = Int(data[5]) * 0x2000
        flags6 = Flags6(rawValue: data[6])
        flags7 = Flags7(rawValue: data[7])
        prgRAMSize = Int(data[8]) * 0x2000
        flags9 = Flags9(rawValue: data[9])
        flags10 = Flags10(rawValue: data[10])
        mapper = flags7.mapperNybble | flags6.mapperNybble
    }
}

extension Cartridge {
    enum Mirroring: UInt8 {
        case horizontal = 0
        case vertical = 1
    }
}

extension Cartridge.Header {
    struct Flags6 { let rawValue: UInt8 }
    struct Flags7 { let rawValue: UInt8 }
    struct Flags9 { let rawValue: UInt8 }
    struct Flags10 { let rawValue: UInt8 }
}

extension Cartridge.Header.Flags6 {
    // 76543210
    // ||||||||
    // |||||||+- Mirroring: 0: horizontal (vertical arrangement) (CIRAM A10 = PPU A11)
    // |||||||              1: vertical (horizontal arrangement) (CIRAM A10 = PPU A10)
    // ||||||+-- 1: Cartridge contains battery-backed PRG RAM ($6000-7FFF) or other persistent memory
    // |||||+--- 1: 512-byte trainer at $7000-$71FF (stored before PRG data)
    // ||||+---- 1: Ignore mirroring control or above mirroring bit; instead provide four-screen VRAM
    // ++++----- Lower nybble of mapper number
    var mirroring: Cartridge.Mirroring { return Cartridge.Mirroring(rawValue: rawValue[bit: 0])! }
    var containsBatteryRAM: Bool { return rawValue[bit: 1].bool }
    var storedBeforePRG: Bool { return rawValue[bit: 2].bool }
    var ignoreMirroring: Bool { return rawValue[bit: 3].bool }
    var mapperNybble: UInt8 { return rawValue >> 4 }
}

extension Cartridge.Header.Flags7 {
    // 76543210
    // ||||||||
    // |||||||+- VS Unisystem
    // ||||||+-- PlayChoice-10 (8KB of Hint Screen data stored after CHR data)
    // ||||++--- If equal to 2, flags 8-15 are in NES 2.0 format
    // ++++----- Upper nybble of mapper number
    var isVSUnisystem: Bool { return rawValue[bit: 0].bool }
    var hasPlayChoice10: Bool { return rawValue[bit: 1].bool }
    var isNES20: Bool { return ((rawValue & 0b0000_1100) >> 2) == 2 }
    var mapperNybble: UInt8 { return rawValue & 0b1111_0000 }
}

extension Cartridge.Header.Flags9 {
    // 76543210
    // ||||||||
    // |||||||+- TV system (0: NTSC; 1: PAL)
    // +++++++-- Reserved, set to zero
    var isNTSC: Bool { return !(rawValue[bit: 0].bool) }
}

extension Cartridge.Header.Flags10 {
    // 76543210
    //   ||  ||
    //   ||  ++- TV system (0: NTSC; 2: PAL; 1/3: dual compatible)
    //   |+----- PRG RAM ($6000-$7FFF) (0: present; 1: not present)
    //   +------ 0: Board has no bus conflicts; 1: Board has bus conflicts
    var presentPrgRAM: Bool { return !(rawValue[bit: 4].bool) }
    var conflicts: Bool { return rawValue[bit: 5].bool }
}

extension Cartridge {

    init?(url: URL) {
        guard let bytes = try? Data(contentsOf: url, options: []) else {
            print("Cartridge: Failed to read the file.")
            return nil
        }

        // read header
        let headerSize = 0x0010
        let header = Header(data: bytes.subdata(in: 0..<headerSize))
        guard header.isValid else {
            print("Cartridge: Invalid iNES header")
            return nil
        }
        self.header = header

        let pROMStart = headerSize
        self.prgROM = bytes.subdata(in: pROMStart ..< (pROMStart+header.prgROMSize))

        if header.chrROMSize == 0 {
            self.chrROM = Data(count: 8 * 1024)
        } else {
            let cROMStart = pROMStart + header.prgROMSize
            self.chrROM = bytes.subdata(in: cROMStart ..< (cROMStart+header.chrROMSize))
        }
    }
}

extension Cartridge: CustomStringConvertible {
    var description: String {
        var a: [String] = []
        a.append("program ROM size=$\(header.prgROMSize.hex4) (\(header.prgROMSize/1024)K)")
        a.append("character ROM size=$\(header.chrROMSize.hex4) (\(header.chrROMSize/1024)K)")
        a.append("mirroring=\(header.flags6.mirroring)")
        a.append("mapper number=$\(header.mapper.hex)")
        a.append("program RAM size=$\(header.prgRAMSize.hex4) (\(header.prgRAMSize/1024)K)")
        return a.joined(separator: "\n")
    }
}

extension Cartridge.Mirroring {
    var bg: Memory {
        switch self {
        case .vertical:
            return BGVM()
        case .horizontal:
            return BGHM()
        }
    }
}

extension Cartridge {
    func createNES() -> NES? {
        guard header.mapper == 0 else {
            print("unavailable mapper=$\(header.mapper.hex)")
            return nil
        }
        let mapper = NROM(data: prgROM)
        let chrmem = DRAM(data: chrROM)
        let sprmem = DRAM(data: Data(count: 256))
        let ppu = PPU(chrmem: chrmem, vram: header.flags6.mirroring.bg, sprmem: sprmem)
        let pad = Pad()
        let apu = APU()
        let ram = WRAM()
        let bus = BUS(ram: ram, ppu: ppu, pad: pad, apu: apu, mapper: mapper)
        let dma = DMA(src: bus, ppu: ppu, dst: sprmem)
        let reg = Register(a: 0, x: 0, y: 0, s: 0xFD, p: Register.P(rawValue: 0x34), pc: 0)
        let cpu = CPU(reg: reg, mem: dma)
        return NES(cpu: cpu, dma: dma, ppu: ppu, pad: pad, apu: apu)
    }
}

struct NES {
    let cpu: CPU
    let dma: DMA
    let ppu: PPU
    let pad: Pad
    let apu: APU
}
