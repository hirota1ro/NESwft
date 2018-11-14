//
//  PPUTests.swift
//  NESwftTests
//
//  Created by HIROTA Ichiro on 2018/10/25.
//  Copyright © 2018 HIROTA Ichiro. All rights reserved.
//

import XCTest
@testable import NESwft

class PPUTests: XCTestCase {

    func testStat() {
        var stat = PPU.Stat()
        stat.rawValue[bit: 7] = 1
        XCTAssertTrue(stat.vblank)
        stat.rawValue[bit: 7] = 0
        XCTAssertFalse(stat.vblank)
        stat.rawValue[bit: 6] = 1
        XCTAssertTrue(stat.spr0hit)
        stat.rawValue[bit: 6] = 0
        XCTAssertFalse(stat.spr0hit)
    }

    func testPPUCtrl() {
        var ctrl = PPU.Ctrl()

        ctrl.rawValue = 0
        XCTAssertEqual(ctrl.baseNameTable, 0)
        ctrl.rawValue = 1
        XCTAssertEqual(ctrl.baseNameTable, 1)
        ctrl.rawValue = 2
        XCTAssertEqual(ctrl.baseNameTable, 2)
        ctrl.rawValue = 3
        XCTAssertEqual(ctrl.baseNameTable, 3)

        ctrl.rawValue[bit: 2] = 0
        XCTAssertEqual(ctrl.addrIncr, 1)
        ctrl.rawValue[bit: 2] = 1
        XCTAssertEqual(ctrl.addrIncr, 32)

        ctrl.rawValue[bit: 3] = 0
        XCTAssertEqual(ctrl.spPatTable, 0x0000)
        ctrl.rawValue[bit: 3] = 1
        XCTAssertEqual(ctrl.spPatTable, 0x1000)

        ctrl.rawValue[bit: 4] = 0
        XCTAssertEqual(ctrl.bgPatTable, 0x0000)
        ctrl.rawValue[bit: 4] = 1
        XCTAssertEqual(ctrl.bgPatTable, 0x1000)

        ctrl.rawValue[bit: 5] = 0
        XCTAssertEqual(ctrl.spriteHeight, 8)
        ctrl.rawValue[bit: 5] = 1
        XCTAssertEqual(ctrl.spriteHeight, 16)

        ctrl.rawValue[bit: 7] = 0
        XCTAssertFalse(ctrl.generateNMI)
        ctrl.rawValue[bit: 7] = 1
        XCTAssertTrue(ctrl.generateNMI)
    }

    func testPPUMask() {
        var mask = PPU.Mask()

        mask.rawValue[bit: 0] = 0
        XCTAssertFalse(mask.greyscale)
        mask.rawValue[bit: 0] = 1
        XCTAssertTrue(mask.greyscale)

        mask.rawValue[bit: 1] = 0
        XCTAssertFalse(mask.showBgEdge)
        mask.rawValue[bit: 1] = 1
        XCTAssertTrue(mask.showBgEdge)

        mask.rawValue[bit: 2] = 0
        XCTAssertFalse(mask.showSpEdge)
        mask.rawValue[bit: 2] = 1
        XCTAssertTrue(mask.showSpEdge)

        mask.rawValue[bit: 3] = 0
        XCTAssertFalse(mask.showBg)
        mask.rawValue[bit: 3] = 1
        XCTAssertTrue(mask.showBg)

        mask.rawValue[bit: 4] = 0
        XCTAssertFalse(mask.showSp)
        mask.rawValue[bit: 4] = 1
        XCTAssertTrue(mask.showSp)

        mask.rawValue = 0b0000_0000
        XCTAssertEqual(mask.emphasis, PPU.Mask.Emphasis(r: false, g: false, b: false))
        mask.rawValue = 0b0010_0000
        XCTAssertEqual(mask.emphasis, PPU.Mask.Emphasis(r: true, g: false, b: false))
        mask.rawValue = 0b0100_0000
        XCTAssertEqual(mask.emphasis, PPU.Mask.Emphasis(r: false, g: true, b: false))
        mask.rawValue = 0b1000_0000
        XCTAssertEqual(mask.emphasis, PPU.Mask.Emphasis(r: false, g: false, b: true))
    }

    func testPalPix() {
        let pp12 = PalPix(palette: 1, pixel: 2)
        XCTAssertEqual(pp12.palette, 1)
        XCTAssertEqual(pp12.pixel, 2)
        let pp30 = PalPix(palette: 3, pixel: 0)
        XCTAssertEqual(pp30.palette, 3)
        XCTAssertEqual(pp30.pixel, 0)
    }

    func testPPU() {
        let chrmem = DRAM(data: Data(count: 0x1000))
        let sprmem = DRAM(data: Data(count: 256))
        let ppu = PPU(chrmem: chrmem, vram: BGVM(), sprmem: sprmem)

        ppu[0x2000] = 0xAB // write PPUCTRL
        XCTAssertEqual(ppu.ctrl.rawValue, 0xAB)
        ppu[0x2001] = 0xCD // write PPUMASK
        XCTAssertEqual(ppu.mask.rawValue, 0xCD)

        ppu.writeLatchW = true
        ppu.stat.vblank = true
        let stat = ppu[0x2002] // read PPUSTATUS($2002), reset $2006 writing status, clear vblank
        XCTAssertEqual(stat, 0x80)
        XCTAssertFalse(ppu.writeLatchW)
        XCTAssertFalse(ppu.stat.vblank)

        ppu[0x2003] = 0x12      // write OAMADDR
        XCTAssertEqual(ppu.sprAddr, 0x12)
        ppu[0x2004] = 0xAB      // write OAMDATA
        XCTAssertEqual(ppu.sprAddr, 0x13) // sprite address incremented
        ppu[0x2003] = 0x12      // write OAMADDR
        let ff = ppu[0x2004]    // read OAMDATA
        XCTAssertEqual(ff, 0xAB)
        XCTAssertEqual(ppu.sprAddr, 0x12) // sprite address unchanged

        // $3F10 = Sprite Palette #0:0
        ppu[0x2006] = 0x3F // write PPUADDR H
        ppu[0x2006] = 0x10 // write PPUADDR L
        XCTAssertEqual(ppu.ppuAddr, 0x3F10)
        ppu[0x2007] = 0x2C // write PPUDATA
        XCTAssertEqual(ppu.ppuAddr, 0x3F11) // address incremented

        ppu[0x2006] = 0x3F // write PPUADDR H
        ppu[0x2006] = 0x10 // write PPUADDR L
        let dd = ppu[0x2007] // read PPUDATA
        XCTAssertEqual(dd, 0x2C)

        // $3F00 = BG Palette #0:0
        ppu[0x2006] = 0x3F // write PPUADDR H
        ppu[0x2006] = 0x00 // write PPUADDR L
        let ee = ppu[0x2007] // read PPUDATA
        XCTAssertEqual(ee, 0x2C) // $3F10 is mirror of $3F00

        ppu[0x2005] = 54 // write PPUSCROLL X
        ppu[0x2005] = 32 // write PPUSCROLL Y
        XCTAssertEqual(ppu.scroll, Point(x: 54, y: 32))
    }
}

extension PPU.Mask.Emphasis: Equatable {
    public static func == (a: PPU.Mask.Emphasis, b: PPU.Mask.Emphasis) -> Bool {
        return a.rawValue == b.rawValue
    }

    init(r: Bool, g: Bool, b: Bool) {
        self.init(rawValue: (b.byte<<2) | (g.byte<<1) | r.byte)
    }
}
