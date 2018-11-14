//
//  MemoryTests.swift
//  NESwftTests
//
//  Created by HIROTA Ichiro on 2018/10/25.
//  Copyright © 2018 HIROTA Ichiro. All rights reserved.
//

import XCTest
@testable import NESwft

class MemoryTests: XCTestCase {

    func testMemory() {
        let mem = RAM64K()
        mem[0x0000] = 0x12
        XCTAssertEqual(mem[0x0000], 0x12)
        mem[0x0001] = 0x34
        XCTAssertEqual(mem[0x0001], 0x34)
        XCTAssertEqual(mem[word: 0x0000], 0x3412)

        mem[word: 0x0002] = 0xABCD
        XCTAssertEqual(mem[0x0002], 0xCD)
        XCTAssertEqual(mem[0x0003], 0xAB)

        mem[pagebound: 0x10FF] = 0x5678
        XCTAssertEqual(mem[0x10FF], 0x78)
        XCTAssertEqual(mem[0x1000], 0x56)
        mem[0x11FF] = 0x12
        mem[0x1100] = 0x34
        XCTAssertEqual(mem[pagebound: 0x11FF], 0x3412)
    }

    func testWRAM() {
        let ram = WRAM()

        ram[0x0000] = 0x12
        XCTAssertEqual(ram[0x0000], 0x12)
        ram[0x07FF] = 0xEF
        XCTAssertEqual(ram[0x07FF], 0xEF)
        // mirror
        XCTAssertEqual(ram[0x1000], 0x12)
        XCTAssertEqual(ram[0x17FF], 0xEF)
    }

    func testBUS() {
        let ram = RAM64K()
        let ppu = RAM64K()
        let pad = RAM64K()
        let apu = RAM64K()
        let mpr = RAM64K()
        let bus = BUS(ram: ram, ppu: ppu, pad: pad, apu: apu, mapper: mpr)

        bus[0x0000] = 0x12
        XCTAssertEqual(ram[0x0000], 0x12)
        bus[0x1001] = 0x34
        XCTAssertEqual(ram[0x1001], 0x34)
        bus[0x2002] = 0x56
        XCTAssertEqual(ppu[0x2002], 0x56)
        bus[0x3003] = 0x78
        XCTAssertEqual(ppu[0x2003], 0x78) // mirror

        bus[0x4015] = 0x9A
        XCTAssertEqual(apu[0x4015], 0x9A)
        bus[0x4016] = 0xBC
        XCTAssertEqual(pad[0x4016], 0xBC)
        bus[0x4017] = 0xDE
        XCTAssertEqual(pad[0x4017], 0xDE)
        bus[0x4018] = 0xF0
        XCTAssertEqual(apu[0x4018], 0xF0)
        bus[0x4020] = 0x12
        XCTAssertEqual(mpr[0x4020], 0x12)

        bus[0x5000] = 0x34
        XCTAssertEqual(mpr[0x5000], 0x34)
    }

    func testDMA() {
        let src = RAM64K()
        let ppu = RAM64K()
        let dst = RAM64K()
        let dma = DMA(src: src, ppu: ppu, dst: dst)

        src[0x1200 + 0x00] = 0xAB
        src[0x1200 + 0xFF] = 0xEF

        ppu[0x2003] = 0x00 // destination address (low)
        dma[0x4014] = 0x12 // source address (high)

        XCTAssertEqual(dst[0x0000], 0xAB)
        XCTAssertEqual(dst[0x00FF], 0xEF)
    }
}

class RAM64K: Memory {

    class Page: Memory {
        var data = Data(repeating: 0, count: 0x0100)
        subscript(addr: UInt16) -> UInt8 {
            get {
                guard addr < 0x0100 else {
                    fatalError("SEGV $\(addr.hex)")
                }
                return data[Int(addr)]
            }
            set {
                guard addr < 0x0100 else {
                    fatalError("SEGV $\(addr.hex) ← $\(newValue.hex)")
                }
                data[Int(addr)] = newValue
            }
        }
    }

    var mmap: [UInt8: Page] = [:]

    func ensure(addr: UInt16) -> Page {
        let hh = UInt8((addr >> 8) & 0xFF)
        if let p = mmap[hh] {
            return p
        }
        let page = Page()
        mmap[hh] = page
        return page
    }

    subscript(addr: UInt16) -> UInt8 {
        get {
            let page = ensure(addr: addr)
            return page[addr & 0x00FF]
        }
        set {
            let page = ensure(addr: addr)
            page[addr & 0x00FF] = newValue
        }
    }
}
