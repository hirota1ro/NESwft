//
//  PPU.swift
//  NESwft
//
//  Created by HIROTA Ichiro on 2018/10/23.
//  Copyright © 2018 HIROTA Ichiro. All rights reserved.
//

import Foundation

// RP2C02 (5.37MHz) Picture Processing Unit
class PPU {

    let chrmem: DRAM
    let vram: Memory
    let sprmem: DRAM

    let palmem = PalMem()
    var bitmap = Bitmap(width: 256, height: 240)
    var prFront = PreRender(baseLine: 0)
    var prBack = PreRender(baseLine: 0)
    var prBG = PreRender(baseLine: 0)
    var stat = Stat()
    var ctrl = Ctrl()
    var mask = Mask()
    var scanLine: Int = 0 // (0...261)
    var clocks: Int = 0
    weak var callback: PPUCallback? = nil

    struct Stat { var rawValue: UInt8 = 0 }
    struct Ctrl { var rawValue: UInt8 = 0 }
    struct Mask { var rawValue: UInt8 = 0 }

    init(chrmem: DRAM, vram: Memory, sprmem: DRAM) {
        self.chrmem = chrmem
        self.vram = vram
        self.sprmem = sprmem
    }

    var writeLatchW = false
    var ppuAddr: UInt16 = 0

    func writePpuAddr(_ dd: UInt8) {
        if writeLatchW {
            ppuAddr.lo = dd
        } else {
            ppuAddr.hi = dd
        }
        writeLatchW = !writeLatchW
    }

    var sprAddr: UInt8 = 0
    var scroll: Point = Point(x: 0, y: 0)

    func writeScroll(_ dd: UInt8) {
        if writeLatchW {
            scroll = Point(x: scroll.x, y: Int(dd))
        } else {
            scroll = Point(x: Int(dd), y: scroll.y)
        }
        writeLatchW = !writeLatchW
    }

    var readBuf: UInt8 = 0

    subscript(bufferd addr: UInt16) -> UInt8 {
        get {
            if addr.hi == 0x3F { // palette
                readBuf = self[mmap: addr]
                return readBuf
            } else {
                defer { readBuf = self[mmap: addr] }
                return readBuf
            }
        }
        set {
            self[mmap: addr] = newValue
        }
    }

    var statusByte: UInt8 {
        get {
            defer { stat.vblank = false }
            // reset PPUSCROLL($2005), PPUADDR($2006) writing status
            writeLatchW = false
            return stat.rawValue
        }
    }

    var ppuData: UInt8 {
        get {
            defer { ppuAddr &+= ctrl.addrIncr }
            return self[bufferd: ppuAddr]
        }
        set {
            defer { ppuAddr &+= ctrl.addrIncr }
            self[bufferd: ppuAddr] = newValue
        }
    }

    func reset() {
        ctrl.rawValue = 0
        mask.rawValue = 0
        sprAddr = 0
        writeLatchW = false
        scroll = Point(x: 0, y: 0)
        readBuf = 0
        scanLine = 0
        clocks = 0
    }
}

protocol PPUCallback: AnyObject {
    func vBlankBegin(ppu: PPU, genNMI: Bool)
    func vBlankEnd(ppu: PPU)
}

extension PPU: Memory {

    // I/O Register
    enum Reg: UInt16 {
        case PPUCTRL   = 0x2000
        case PPUMASK   = 0x2001
        case PPUSTATUS = 0x2002
        case OAMADDR   = 0x2003
        case OAMDATA   = 0x2004
        case PPUSCROLL = 0x2005
        case PPUADDR   = 0x2006
        case PPUDATA   = 0x2007
    }

    /**
     * @param addr I/O Address (0x2000...0x2007)
     * @return Register value
     */
    subscript(addr: UInt16) -> UInt8 {
        get {
            guard let r = Reg(rawValue: addr) else {
                assert(false, "PPU:REG:SEGV(\(addr.hex))")
                return 0
            }
            switch r {
            case .PPUCTRL:
                return ctrl.rawValue
            case .PPUMASK:
                return mask.rawValue
            case .PPUSTATUS:
                return statusByte
            case .OAMADDR:
                return sprAddr
            case .OAMDATA:
                return sprData
            case .PPUSCROLL:
                return 0
            case .PPUADDR:
                return 0
            case .PPUDATA:
                return ppuData
            }
        }
        set {
            guard let r = Reg(rawValue: addr) else {
                assert(false, "PPU:REG:SEGV(\(addr.hex))←\(newValue.hex)")
                return
            }
            switch r {
            case .PPUCTRL:
                ctrl.rawValue = newValue
            case .PPUMASK:
                mask.rawValue = newValue
            case .PPUSTATUS:
                break
            case .OAMADDR:
                sprAddr = newValue
            case .OAMDATA:
                sprData = newValue
            case .PPUSCROLL:
                writeScroll(newValue)
            case .PPUADDR:
                writePpuAddr(newValue)
            case .PPUDATA:
                ppuData = newValue
            }
        }
    }
}

// PPU Addr		Size	Description
// 0x0000～0x0FFF	0x1000	pattern table 0
// 0x1000～0x1FFF	0x1000	pattern table 1
// 0x2000～0x23BF	0x03C0	name table 0
// 0x23C0～0x23FF	0x0040	attribute table 0
// 0x2400～0x27BF	0x03C0	name table 1
// 0x27C0～0x27FF	0x0040	attribute table 1
// 0x2800～0x2BBF	0x03C0	name table 2
// 0x2BC0～0x2BFF	0x0040	attribute table 2
// 0x2C00～0x2FBF	0x03C0	name table 3
// 0x2FC0～0x2FFF	0x0040	attribute table 3
// 0x3000～0x3EFF	-	mirror of 0x2000-0x2EFF
// 0x3F00～0x3F0F	0x0010	background palette
// 0x3F10～0x3F1F	0x0010	sprite palette
// 0x3F20～0x3FFF	-	mirror of 0x3F00-0x3F1F ×7
extension PPU {

    // PPU Memory Map
    subscript(mmap addr: UInt16) -> UInt8 {
        get {
            assert(addr < 0x4000)
            switch (addr >> 12) {
            case 0, 1:
                return chrmem[addr]
            case 2, 3:
                if addr < 0x3F00 {
                    return vram[addr & 0xEFFF]
                } else {
                    return palmem[mirror: addr & 0x3F1F]
                }
            default:
                break
            }
            return 0
        }
        set {
            assert(addr < 0x4000)
            switch (addr >> 12) {
            case 0, 1:
                chrmem[addr] = newValue
            case 2, 3:
                if addr < 0x3F00 {
                    vram[addr & 0xEFFF] = newValue
                } else {
                    palmem[mirror: addr & 0x3F1F] = newValue
                }
            default:
                break
            }
        }
    }
}

extension PPU.Stat {
    // 7  bit  0
    // ---- ----
    // VSO. ....
    // |||| ||||
    // |||+-++++- Least significant bits previously written into a PPU register
    // |||        (due to register not being updated for this address)
    // ||+------- Sprite overflow. The intent was for this flag to be set
    // ||         whenever more than eight sprites appear on a scanline, but a
    // ||         hardware bug causes the actual behavior to be more complicated
    // ||         and generate false positives as well as false negatives; see
    // ||         PPU sprite evaluation. This flag is set during sprite
    // ||         evaluation and cleared at dot 1 (the second dot) of the
    // ||         pre-render line.
    // |+-------- Sprite 0 Hit.  Set when a nonzero pixel of sprite 0 overlaps
    // |          a nonzero background pixel; cleared at dot 1 of the pre-render
    // |          line.  Used for raster timing.
    // +--------- Vertical blank has started (0: not in vblank; 1: in vblank).
    //            Set at dot 1 of line 241 (the line *after* the post-render
    //            line); cleared after reading $2002 and at dot 1 of the
    //            pre-render line.

    var vblank: Bool {
        get { return rawValue[bit: 7].bool }
        set { rawValue[bit: 7] = newValue.byte }
    }

    var spr0hit: Bool {
        get { return rawValue[bit: 6].bool }
        set { rawValue[bit: 6] = newValue.byte }
    }
}

extension PPU.Stat: CustomStringConvertible {
    var description: String {
        let r = self.rawValue
        let a: [String] = ["V", "S", "O", ".", ".", ".", ".", "."]
        let b = a.enumerated().map { (i,s) in r[bit: 7-i].bool ? s : "_" }
        return b.joined(separator: "")
    }
}

extension PPU.Ctrl {
    // 7  bit  0
    // ---- ----
    // VPHB SINN
    // |||| ||||
    // |||| ||++- Base nametable address
    // |||| ||    (0 = $2000; 1 = $2400; 2 = $2800; 3 = $2C00)
    // |||| |+--- VRAM address increment per CPU read/write of PPUDATA
    // |||| |     (0: add 1, going across; 1: add 32, going down)
    // |||| +---- Sprite pattern table address for 8x8 sprites
    // ||||       (0: $0000; 1: $1000; ignored in 8x16 mode)
    // |||+------ Background pattern table address (0: $0000; 1: $1000)
    // ||+------- Sprite size (0: 8x8 pixels; 1: 8x16 pixels)
    // |+-------- PPU master/slave select
    // |          (0: read backdrop from EXT pins; 1: output color on EXT pins)
    // +--------- Generate an NMI at the start of the
    //            vertical blanking interval (0: off; 1: on)
    var baseNameTable: UInt8 { return rawValue & 0b0000_0011 }
    var addrIncr: UInt16 { return UInt16(1 << (rawValue[bit: 2] * 5)) }
    var spPatTable: UInt16 { return UInt16(rawValue[bit: 3]) << 12 }
    var bgPatTable: UInt16 { return UInt16(rawValue[bit: 4]) << 12 }
    var sprite16: Bool { return rawValue[bit: 5].bool }
    var spriteHeight: Int { return 8 << rawValue[bit: 5] }
    var generateNMI: Bool { return rawValue[bit: 7] != 0 }
}

extension PPU.Ctrl: CustomStringConvertible {
    var description: String {
        let r = self.rawValue
        let a: [String] = ["V", "P", "H", "B", "S", "I", "N", "N"]
        let b = a.enumerated().map { (i,s) in r[bit: 7-i].bool ? s : "_" }
        return b.joined(separator: "")
    }
}

extension PPU.Mask {
    // 7  bit  0
    // ---- ----
    // BGRs bMmG
    // |||| ||||
    // |||| |||+- Greyscale (0: normal color, 1: produce a greyscale display)
    // |||| ||+-- 1: Show background in leftmost 8 pixels of screen, 0: Hide
    // |||| |+--- 1: Show sprites in leftmost 8 pixels of screen, 0: Hide
    // |||| +---- 1: Show background
    // |||+------ 1: Show sprites
    // ||+------- Emphasize red*
    // |+-------- Emphasize green*
    // +--------- Emphasize blue

    var greyscale: Bool { return rawValue[bit: 0].bool }
    var showBgEdge: Bool { return rawValue[bit: 1].bool }
    var showSpEdge: Bool { return rawValue[bit: 2].bool }
    var showBg: Bool { return rawValue[bit: 3].bool }
    var showSp: Bool { return rawValue[bit: 4].bool }
    var emphasis: Emphasis { return Emphasis(rawValue: rawValue >> 5) }

    struct Emphasis {
        let rawValue: UInt8
        var red: Bool   { return rawValue[bit: 0].bool }
        var green: Bool { return rawValue[bit: 1].bool }
        var blue: Bool  { return rawValue[bit: 2].bool }
    }
}

extension PPU.Mask: CustomStringConvertible {
    var description: String {
        let r = self.rawValue
        let a: [String] = ["B", "G", "R", "s", "b", "M", "m", "G"]
        let b = a.enumerated().map { (i,s) in r[bit: 7-i].bool ? s : "_" }
        return b.joined(separator: "")
    }
}

// Palette
extension PPU {

    /**
     * @param palette number (0...3)
     * @param base bg=0x3F00, sp=0x3F10
     */
    func palette(number: UInt8, base: UInt16) -> Palette {
        let addr = base + UInt16(number * 4)
        return Palette(palmem: palmem, addr: addr)
    }
    func palette(sp: UInt8) -> Palette {
        return palette(number: sp, base: 0x3F10)
    }
    func palette(bg: UInt8) -> Palette {
        return palette(number: bg, base: 0x3F00)
    }
}

// Sprite Memory
extension PPU {

    var sprData: UInt8 {
        get {
            // Address should not increment on $2004 read
            return sprmem[UInt16(sprAddr)]
        }
        set {
            defer { sprAddr &+= 1 }
            sprmem[UInt16(sprAddr)] = newValue
        }
    }

    /**
     * @return array of Sprite
     */
    var sprites: [Sprite] {
        var a: [Sprite] = []
        for i: UInt8 in 0..<64 {
            a.append(sprite(number: i))
        }
        return a
    }
}

// Sprite
extension PPU {

    /**
     * @param address (0...256-4)
     * @return sprite
     */
    func sprite(addr: Int) -> Sprite { return Sprite(data: sprmem.subdata(in: addr ..< (addr+4))) }

    /**
     * @param sprite number (0..<64)
     * @return sprite
     */
    func sprite(number i: UInt8) -> Sprite { return sprite(addr: Int(i) * 4) }
}

// Pattern
extension PPU {

    func pattern8(number: UInt8, base: UInt16) -> Pat8 {
        let addr = Int(UInt16(number) * 16 + base)
        return Pat8(data: chrmem.subdata(in: addr..<(addr + 16)))
    }

    func pattern8(bg: UInt8) -> Pat8 {
        return pattern8(number: bg, base: ctrl.bgPatTable)
    }

    func pattern8(sp: UInt8) -> Pat8 {
        return pattern8(number: sp, base: ctrl.spPatTable)
    }

    func pattern16(sp: UInt8) -> Pat16 {
        let patn = sp & 0b11111110
        let base = UInt16(sp & 1) << 12
        return Pat16(top: pattern8(number: patn, base: base),
                     bottom: pattern8(number: patn+1, base: base))
    }

    func pattern(sprite: Sprite) -> Pattern {
        var pat: Pattern = ctrl.sprite16 ? pattern16(sp: sprite.p) : pattern8(sp: sprite.p)
        if sprite.a.vFlip {
            pat = VFlip(pat: pat)
        }
        if sprite.a.hFlip {
            pat = HFlip(pat: pat)
        }
        return pat
    }
}

// Rendering
extension PPU {
    static let cIDtoRGB: [UInt32] = [
      0x808080, 0x003DA6, 0x0012B0, 0x440096,
      0xA1005E, 0xC70028, 0xBA0600, 0x8C1700,
      0x5C2F00, 0x104500, 0x054A00, 0x00472E,
      0x004166, 0x000000, 0x050505, 0x050505,
      0xC7C7C7, 0x0077FF, 0x2155FF, 0x8237FA,
      0xEB2FB5, 0xFF2950, 0xFF2200, 0xD63200,
      0xC46200, 0x358000, 0x058F00, 0x008A55,
      0x0099CC, 0x212121, 0x090909, 0x090909,
      0xFFFFFF, 0x0FD7FF, 0x69A2FF, 0xD480FF,
      0xFF45F3, 0xFF618B, 0xFF8833, 0xFF9C12,
      0xFABC20, 0x9FE30E, 0x2BF035, 0x0CF0A4,
      0x05FBFF, 0x5E5E5E, 0x0D0D0D, 0x0D0D0D,
      0xFFFFFF, 0xA6FCFF, 0xB3ECFF, 0xDAABEB,
      0xFFA8F9, 0xFFABB3, 0xFFD2B0, 0xFFEFA6,
      0xFFF79C, 0xD7E895, 0xA6EDAF, 0xA2F2DA,
      0x99FFFC, 0xDDDDDD, 0x111111, 0x111111,
    ]

    var sprite0hit: Bool {
        if mask.showBg && mask.showSp {
            let spr0 = sprite(number: 0)
            return spr0.y == scanLine
        }
        return false
    }

    /**
     * @param clocks PPU clocks
     */
    func step(clocks c: Int) {
        clocks += c
        while 341 < clocks {
            clocks -= 341
            lineByLine()
        }
    }

    func lineByLine() {
        if 0 <= scanLine && scanLine <= 239 { // Visible scanlines (0-239)
            stat.spr0hit = sprite0hit
            if (scanLine % 8) == 0 {
                prerender(scanLine: scanLine)
            }
            render(scanLine: scanLine)
            scanLine += 1
        } else if scanLine == 240 { // post-render scanline
            stat.vblank = true
            callback?.vBlankBegin(ppu: self, genNMI: ctrl.generateNMI)
            scanLine += 1
        } else if 241 <= scanLine && scanLine <= 260 { // Vertical blanking lines (241-260)
            scanLine += 1
        } else { // Pre-render scanline (-1, 261)
            stat.rawValue = 0 // vblank ← false, spr0hit ← false
            callback?.vBlankEnd(ppu: self)
            scanLine = 0
        }
    }

    /**
     * @param scanLine (0...239)
     */
    func render(scanLine y: Int) {
        for x in 0 ..< 256 {
            let cID = color(x: x, y: y)      // 0b00VVHHHH
            let rgb = PPU.cIDtoRGB[Int(cID)] // 0x00RRGGBB
            bitmap[x, y] = rgb
        }
    }

    /**
     * @param x (0 ..< 256)
     * @param y (0 ..< 240) (scanLine ..< scanLine+8)
     * @return color ID (0x00 ... 0x3F)
     */
    func color(x: Int, y: Int) -> UInt8 {
        let fpp = prFront[x, y]
        if fpp.opaque {
            let pal = palette(sp: fpp.palette)
            return pal[fpp.pixel]
        }
        let pp = prBG[x, y]
        if pp.opaque {
            let pal = palette(bg: pp.palette)
            return pal[pp.pixel]
        }
        let bpp = prBack[x, y]
        if bpp.opaque {
            let pal = palette(sp: bpp.palette)
            return pal[bpp.pixel]
        }

        let dpal = palette(bg: 0)
        return dpal[0]
    }

    /**
     * @param scanLine (0...239)
     */
    func prerender(scanLine: Int) {
        assert((scanLine % 8) == 0)
        prFront = PreRender(baseLine: scanLine)
        prBack = PreRender(baseLine: scanLine)
        if mask.showSp {
            prerenderSP(scanLine: scanLine, bounds: prFront.rect)
        }
        prBG = PreRender(baseLine: scanLine)
        if mask.showBg {
            prerenderBG(scanLine: scanLine, bounds: prBG.rect)
        }
    }

    func prerenderSP(scanLine: Int, bounds: Rect) {
        sprites.forEach { s in
            let r = Rect(x: s.x, y: s.y + 1, width: 8, height: ctrl.spriteHeight) // +1 because sprite.y is (screen.y - 1)
            if bounds.intersects(rect: r) {
                prerender(sprite: s, rect: r, bounds: bounds)
            }
        }
    }

    /**
     * @param sprite rendering source
     * @param rect of sprite (screen coordinate)
     * @param bounds rect of pre-rendering buffer
     */
    func prerender(sprite s: Sprite, rect r: Rect, bounds: Rect) {
        r.forEach { p in
            if bounds.contains(point: p) {
                let q = p - r.origin // sprite local coordinate
                let pat = pattern(sprite: s)
                let pix = pat[q.x, q.y]
                let pp = PalPix(palette: s.a.palette, pixel: pix)
                if pp.opaque {
                    if s.a.behind {
                        prBack[p.x, p.y] = pp
                    } else {
                        prFront[p.x, p.y] = pp
                    }
                }
            }
        }
    }

    func prerenderBG(scanLine: Int, bounds: Rect) {
        let so8 = scroll % 8
        let nn = Int(ctrl.baseNameTable)
        let bnn = Point(x: ((nn >> 0) & 1) * 256, y: ((nn >> 1) & 1) * 240)
        let tso = (bnn + scroll) / 8
        let tLT = Point(x: 0, y: scanLine) / 8 + tso
        let tRB = Point(x: 256-1, y: scanLine+7) / 8 + tso
        let tBounds = Rect(origin: tLT, size: Size(point: tRB - tLT + Point(x: 1, y: 1)))
        tBounds.forEach { t in
            // retrieve pattern
            let tfld = Point(x: t.x % 32, y: t.y % 30)
            let bbbb = (((t.y / 30) & 1) * 2 + ((t.x / 32) & 1)) * 0x400 + 0x2000
            let nnnn = UInt16(bbbb + tfld.y * 32 + tfld.x)
            let patn = vram[nnnn]
            let pat = pattern8(bg: patn)
            // retrieve palette
            let t4 = tfld / 4
            let aaaa = UInt16(bbbb + t4.y * 8 + t4.x + 0x03C0)
            let dd = vram[aaaa]
            let hl = (t % 4) / 2
            let bits = (hl.y * 2 + hl.x) * 2
            let paln = (dd >> bits) & 3
            // render pattern
            let porg = (t - tso) * 8 - so8
            pat.size.forEach { q in // pattern local coordinate
                let p = porg + q // screen coordinate
                if bounds.contains(point: p) {
                    let pix = pat[q.x, q.y]
                    prBG[p.x, p.y] = PalPix(palette: paln, pixel: pix)
                }
            }
        }
    }

    // Sprite(front, back), BG <PalPix>
    struct PreRender {
        let baseLine: Int
        var map: [PalPix] = Array(repeating: PalPix(rawValue:0), count: 256 * 8)
        init(baseLine: Int) { self.baseLine = baseLine }

        /**
         * @param x (0..<256)
         * @return pair of palette and pixel
         */
        subscript(x: Int, y: Int) -> PalPix {
            get {
                assert(0 <= x && x < 256)
                assert(baseLine <= y && y < (baseLine + 8))
                let i = (y - baseLine) * 256 + x
                return map[i]
            }
            set {
                assert(0 <= x && x < 256)
                assert(baseLine <= y && y < (baseLine + 8))
                let i = (y - baseLine) * 256 + x
                map[i] = newValue
            }
        }
    }
}

extension PPU.PreRender {
    var rect: Rect {
        return Rect(x: 0, y: baseLine, width: 256, height: 8)
    }
}

struct PalPix {
    // 7  bit  0
    // xxxx LLXX
    //      ||++- pixel number (0...3)
    //      ++--- palette number (0...3)
    let rawValue: UInt8
}

extension PalPix {
    var palette: UInt8 { return (rawValue >> 2) & 3 }
    var pixel: UInt8 { return rawValue & 3 }
    init(palette: UInt8, pixel: UInt8) {
        assert(palette < 4)
        assert(pixel < 4)
        self.init(rawValue: (palette << 2) | pixel)
    }

    var opaque: Bool { return (pixel != 0) }
}
