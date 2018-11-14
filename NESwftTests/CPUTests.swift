//
//  CPUTests.swift
//  NESwftTests
//
//  Created by HIROTA Ichiro on 2018/10/22.
//  Copyright © 2018 HIROTA Ichiro. All rights reserved.
//

import XCTest
@testable import NESwft

class CPUTests: XCTestCase {

    var cpu: CPU!

    override func setUp() {
        cpu = CPU(reg: Register(a: 0, x: 0, y: 0, s: 0xff, p: Register.P(rawValue: 0), pc: 0x8000),
                  mem: RAM64K())
    }

    override func tearDown() {
    }

    func testADC() {
// C91C  69 69     ADC #$69                        A:00 X:00 Y:00 P:6E SP:FB CYC:217 SL:245
// C91E  30 0B     BMI $C92B                       A:69 X:00 Y:00 P:2C SP:FB CYC:223 SL:245
        cpu.reg.a = 0x00
        cpu.reg.p = Register.P(rawValue: 0x6E)
        cpu.ADC(0x69)
        XCTAssertEqual(cpu.reg.a, 0x69)
        XCTAssertEqual(cpu.reg.p, Register.P(rawValue: 0x2C))
// C936  69 69     ADC #$69                        A:01 X:00 Y:00 P:6D SP:FB CYC:295 SL:245
// C938  30 0B     BMI $C945                       A:6B X:00 Y:00 P:2C SP:FB CYC:301 SL:245
        cpu.reg.a = 0x01
        cpu.reg.p = Register.P(rawValue: 0x6D)
        cpu.ADC(0x69)
        XCTAssertEqual(cpu.reg.a, 0x6B)
        XCTAssertEqual(cpu.reg.p, Register.P(rawValue: 0x2C))
// C94F  69 7F     ADC #$7F                        A:7F X:00 Y:00 P:25 SP:FB CYC: 29 SL:246
// C951  10 0B     BPL $C95E                       A:FF X:00 Y:00 P:E4 SP:FB CYC: 35 SL:246
        cpu.reg.a = 0x7F
        cpu.reg.p = Register.P(rawValue: 0x25)
        cpu.ADC(0x7F)
        XCTAssertEqual(cpu.reg.a, 0xFF)
        XCTAssertEqual(cpu.reg.p, Register.P(rawValue: 0xE4))
// C968  69 80     ADC #$80                        A:7F X:00 Y:00 P:64 SP:FB CYC:101 SL:246
// C96A  10 0B     BPL $C977                       A:FF X:00 Y:00 P:A4 SP:FB CYC:107 SL:246
        cpu.reg.a = 0x7F
        cpu.reg.p = Register.P(rawValue: 0x64)
        cpu.ADC(0x80)
        XCTAssertEqual(cpu.reg.a, 0xFF)
        XCTAssertEqual(cpu.reg.p, Register.P(rawValue: 0xA4))
// C980  69 80     ADC #$80                        A:7F X:00 Y:00 P:25 SP:FB CYC:170 SL:246
// C982  D0 09     BNE $C98D                       A:00 X:00 Y:00 P:27 SP:FB CYC:176 SL:246
        cpu.reg.a = 0x7F
        cpu.reg.p = Register.P(rawValue: 0x25)
        cpu.ADC(0x80)
        XCTAssertEqual(cpu.reg.a, 0x00)
        XCTAssertEqual(cpu.reg.p, Register.P(rawValue: 0x27))
    }

    func testSBC() {
// CBB4  E9 40     SBC #$40                        A:40 X:AA Y:71 P:65 SP:FB CYC:336 SL:250
// CBB6  20 37 F9  JSR $F937                       A:00 X:AA Y:71 P:27 SP:FB CYC:  1 SL:251
        cpu.reg.a = 0x40
        cpu.reg.p = Register.P(rawValue: 0x65)
        cpu.SBC(0x40)
        XCTAssertEqual(cpu.reg.a, 0x00)
        XCTAssertEqual(cpu.reg.p, Register.P(rawValue: 0x27))
// CBBD  E9 3F     SBC #$3F                        A:40 X:AA Y:72 P:25 SP:FB CYC:133 SL:251
// CBBF  20 4C F9  JSR $F94C                       A:01 X:AA Y:72 P:25 SP:FB CYC:139 SL:251
        cpu.reg.a = 0x40
        cpu.reg.p = Register.P(rawValue: 0x25)
        cpu.SBC(0x3F)
        XCTAssertEqual(cpu.reg.a, 0x01)
        XCTAssertEqual(cpu.reg.p, Register.P(rawValue: 0x25))
// CBC6  E9 41     SBC #$41                        A:40 X:AA Y:73 P:E5 SP:FB CYC:274 SL:251
// CBC8  20 62 F9  JSR $F962                       A:FF X:AA Y:73 P:A4 SP:FB CYC:280 SL:251
        cpu.reg.a = 0x40
        cpu.reg.p = Register.P(rawValue: 0xE5)
        cpu.SBC(0x41)
        XCTAssertEqual(cpu.reg.a, 0xFF)
        XCTAssertEqual(cpu.reg.p, Register.P(rawValue: 0xA4))
// CBCF  E9 00     SBC #$00                        A:80 X:AA Y:74 P:A4 SP:FB CYC: 65 SL:252
// CBD1  20 76 F9  JSR $F976                       A:7F X:AA Y:74 P:65 SP:FB CYC: 71 SL:252
        cpu.reg.a = 0x80
        cpu.reg.p = Register.P(rawValue: 0xA4)
        cpu.SBC(0x00)
        XCTAssertEqual(cpu.reg.a, 0x7F)
        XCTAssertEqual(cpu.reg.p, Register.P(rawValue: 0x65))
// CBD8  E9 7F     SBC #$7F                        A:81 X:AA Y:75 P:E5 SP:FB CYC:179 SL:252
// CBDA  20 84 F9  JSR $F984                       A:02 X:AA Y:75 P:65 SP:FB CYC:185 SL:252
        cpu.reg.a = 0x81
        cpu.reg.p = Register.P(rawValue: 0xE5)
        cpu.SBC(0x7F)
        XCTAssertEqual(cpu.reg.a, 0x02)
        XCTAssertEqual(cpu.reg.p, Register.P(rawValue: 0x65))
    }

    func testCMP() {
        cpu.reg.a = 2
        cpu.CMP(1) // 2 - 1
        XCTAssertTrue(cpu.reg.p.c)
        XCTAssertFalse(cpu.reg.p.z)
        cpu.reg.a = 2
        cpu.CMP(2) // 2 - 2
        XCTAssertTrue(cpu.reg.p.c)
        XCTAssertTrue(cpu.reg.p.z)
        cpu.reg.a = 2
        cpu.CMP(3) // 2 - 3
        XCTAssertFalse(cpu.reg.p.c)
        XCTAssertFalse(cpu.reg.p.z)
    }

    func test00_BRK_Implied() {
        cpu.mem[0x8000] = 0x00
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test01_ORA_Indirect_X() {
        cpu.mem[0x8000] = 0x01
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.mem[word: 0x00ee] = 0x0077
        cpu.mem[0x0077] = 0x55
        cpu.reg.a = 0xaa
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0xff)
    }
    func test02_STP_Implied() {
        cpu.mem[0x8000] = 0x02
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test03_SLO_Indirect_X() {
        cpu.mem[0x8000] = 0x03
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test04_NOP_ZeroPage() {
        cpu.mem[0x8000] = 0x04
        cpu.mem[0x8001] = 0xdd
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test05_ORA_ZeroPage() {
        cpu.mem[0x8000] = 0x05
        cpu.mem[0x8001] = 0xdd
        cpu.reg.a = 0xaa
        cpu.mem[0x00dd] = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0xff)
    }
    func test06_ASL_ZeroPage() {
        cpu.mem[0x8000] = 0x06
        cpu.mem[0x8001] = 0xdd
        cpu.mem[0x00dd] = 0x55
        cpu.step()
        XCTAssertEqual(cpu.mem[0x00dd], 0xaa)
    }
    func test07_SLO_ZeroPage() {
        cpu.mem[0x8000] = 0x07
        cpu.mem[0x8001] = 0xdd
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test08_PHP_Implied() {
        cpu.mem[0x8000] = 0x08
        cpu.reg.p.rawValue = 0xaa
        cpu.step()
        XCTAssertEqual(cpu.mem[0x01ff], 0xaa | 0b0011_0000)
        XCTAssertEqual(cpu.reg.s, 0xfe)
    }
    func test09_ORA_Immediate() {
        cpu.mem[0x8000] = 0x09
        cpu.mem[0x8001] = 0x55
        cpu.reg.a = 0xaa
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0xff)
    }
    func test0a_ASL_Accumulator() {
        cpu.mem[0x8000] = 0x0a
        cpu.reg.a = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0xaa)
    }
    func test0b_ANC_Immediate() {
        cpu.mem[0x8000] = 0x0b
        cpu.mem[0x8001] = 0xaa
        cpu.reg.a = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x00)
    }
    func test0c_NOP_Absolute() {
        cpu.mem[0x8000] = 0x0c
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test0d_ORA_Absolute() {
        cpu.mem[0x8000] = 0x0d
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.mem[0xaaaa] = 0x55
        cpu.reg.a = 0xaa
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0xff)
    }
    func test0e_ASL_Absolute() {
        cpu.mem[0x8000] = 0x0e
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.mem[0xaaaa] = 0x55
        cpu.step()
        XCTAssertEqual(cpu.mem[0xaaaa], 0xaa)
    }
    func test0f_SLO_Absolute() {
        cpu.mem[0x8000] = 0x0f
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test10_BPL_Relative() {
        cpu.mem[0x8000] = 0x10
        cpu.mem[0x8001] = 0xfe
        cpu.reg.p.n = false
        cpu.step()
        XCTAssertEqual(cpu.reg.pc, 0x8000)
        cpu.reg.p.n = true
        cpu.step()
        XCTAssertEqual(cpu.reg.pc, 0x8002)
    }
    func test11_ORA_Indirect_Y() {
        cpu.mem[0x8000] = 0x11
        cpu.mem[0x8001] = 0xdd
        cpu.mem[word: 0x00dd] = 0x7700
        cpu.reg.y = 0x77
        cpu.mem[0x7777] = 0x55
        cpu.reg.a = 0xaa
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0xff)
    }
    func test12_STP_Implied() {
        cpu.mem[0x8000] = 0x12
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test13_SLO_Indirect_Y() {
        cpu.mem[0x8000] = 0x13
        cpu.mem[0x8001] = 0xdd
        cpu.reg.y = 0x22
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test14_NOP_ZeroPage_X() {
        cpu.mem[0x8000] = 0x14
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test15_ORA_ZeroPage_X() {
        cpu.mem[0x8000] = 0x15
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.mem[0x00ee] = 0x55
        cpu.reg.a = 0xaa
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0xff)
    }
    func test16_ASL_ZeroPage_X() {
        cpu.mem[0x8000] = 0x16
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.mem[0x00ee] = 0x55
        cpu.step()
        XCTAssertEqual(cpu.mem[0x00ee], 0xaa)
    }
    func test17_SLO_ZeroPage_X() {
        cpu.mem[0x8000] = 0x17
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test18_CLC_Implied() {
        cpu.mem[0x8000] = 0x18
        cpu.reg.p.c = true
        cpu.step()
        XCTAssertFalse(cpu.reg.p.c)
    }
    func test19_ORA_Absolute_Y() {
        cpu.mem[0x8000] = 0x19
        cpu.mem[word: 0x8001] = 0x7700
        cpu.reg.y = 0x77
        cpu.mem[0x7777] = 0x55
        cpu.reg.a = 0xaa
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0xff)
    }
    func test1a_NOP_Implied() {
        cpu.mem[0x8000] = 0x1a
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test1b_SLO_Absolute_Y() {
        cpu.mem[0x8000] = 0x1b
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.reg.y = 0x22
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test1c_NOP_Absolute_X() {
        cpu.mem[0x8000] = 0x1c
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.reg.x = 0x11
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test1d_ORA_Absolute_X() {
        cpu.mem[0x8000] = 0x1d
        cpu.mem[word: 0x8001] = 0x7700
        cpu.reg.x = 0x77
        cpu.mem[0x7777] = 0x55
        cpu.reg.a = 0xaa
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0xff)
    }
    func test1e_ASL_Absolute_X() {
        cpu.mem[0x8000] = 0x1e
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.reg.x = 0x11
        cpu.mem[0xaabb] = 0x55
        cpu.step()
        XCTAssertEqual(cpu.mem[0xaabb], 0xaa)
    }
    func test1f_SLO_Absolute_X() {
        cpu.mem[0x8000] = 0x1f
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.reg.x = 0x11
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test20_JSR_Absolute() {
        cpu.mem[0x8000] = 0x20
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.step()
        XCTAssertEqual(cpu.reg.pc, 0xaaaa)
        XCTAssertEqual(cpu.reg.s, 0xfd)
        XCTAssertEqual(cpu.mem[word: 0x01fe], 0x8002)
    }
    func test21_AND_Indirect_X() {
        cpu.mem[0x8000] = 0x21
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.mem[word: 0x00ee] = 0x0077
        cpu.mem[0x0077] = 0x55
        cpu.reg.a = 0xaa
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x00)
    }
    func test22_STP_Implied() {
        cpu.mem[0x8000] = 0x22
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test23_RLA_Indirect_X() {
        cpu.mem[0x8000] = 0x23
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.mem[word: 0x00ee] = 0x0077
        cpu.mem[0x0077] = 0x55
        cpu.reg.a = 0x0f
        cpu.step()
        XCTAssertEqual(cpu.mem[0x0077], 0xaa)
        XCTAssertEqual(cpu.reg.a, 0x0a)
    }
    func test24_BIT_ZeroPage() {
        cpu.mem[0x8000] = 0x24
        cpu.mem[0x8001] = 0xdd
        cpu.reg.a = 0xaa
        cpu.mem[0x00dd] = 0x55
        cpu.step()
        XCTAssertFalse(cpu.reg.p.n)
        XCTAssertTrue(cpu.reg.p.v)
        XCTAssertTrue(cpu.reg.p.z)
    }
    func test25_AND_ZeroPage() {
        cpu.mem[0x8000] = 0x25
        cpu.mem[0x8001] = 0xdd
        cpu.reg.a = 0xaa
        cpu.mem[0x00dd] = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x00)
    }
    func test26_ROL_ZeroPage() {
        cpu.mem[0x8000] = 0x26
        cpu.mem[0x8001] = 0xdd
        cpu.mem[0x00dd] = 0xaa
        cpu.reg.p.c = true
        cpu.step()
        XCTAssertEqual(cpu.mem[0x00dd], 0x55)
        XCTAssertTrue(cpu.reg.p.c)
    }
    func test27_RLA_ZeroPage() {
        cpu.mem[0x8000] = 0x27
        cpu.mem[0x8001] = 0xdd
        cpu.mem[0x00dd] = 0x55
        cpu.reg.a = 0x0f
        cpu.step()
        XCTAssertEqual(cpu.mem[0x00dd], 0xaa)
        XCTAssertEqual(cpu.reg.a, 0x0a)
    }
    func test28_PLP_Implied() {
        cpu.mem[0x8000] = 0x28
        cpu.mem[0x01ff] = 0xaa
        cpu.reg.s = 0xfe
        cpu.step()
        XCTAssertEqual(cpu.reg.p.rawValue, 0xaa)
        XCTAssertEqual(cpu.reg.s, 0xff)
    }
    func test29_AND_Immediate() {
        cpu.mem[0x8000] = 0x29
        cpu.mem[0x8001] = 0xaa
        cpu.reg.a = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x00)
    }
    func test2a_ROL_Accumulator() {
        cpu.mem[0x8000] = 0x2a
        cpu.reg.a = 0xaa
        cpu.reg.p.c = true
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x55)
        XCTAssertTrue(cpu.reg.p.c)
    }
    func test2b_ANC_Immediate() {
        cpu.mem[0x8000] = 0x2b
        cpu.mem[0x8001] = 0xaa
        cpu.reg.a = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x00)
    }
    func test2c_BIT_Absolute() {
        cpu.mem[0x8000] = 0x2c
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.mem[0xaaaa] = 0x55
        cpu.reg.a = 0xaa
        cpu.step()
        XCTAssertFalse(cpu.reg.p.n)
        XCTAssertTrue(cpu.reg.p.v)
        XCTAssertTrue(cpu.reg.p.z)
    }
    func test2d_AND_Absolute() {
        cpu.mem[0x8000] = 0x2d
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.mem[0xaaaa] = 0x55
        cpu.reg.a = 0xaa
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x00)
    }
    func test2e_ROL_Absolute() {
        cpu.mem[0x8000] = 0x2e
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.mem[0xaaaa] = 0xaa
        cpu.reg.p.c = true
        cpu.step()
        XCTAssertEqual(cpu.mem[0xaaaa], 0x55)
        XCTAssertTrue(cpu.reg.p.c)
    }
    func test2f_RLA_Absolute() {
        cpu.mem[0x8000] = 0x2f
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.mem[0xaaaa] = 0x55
        cpu.reg.a = 0x0f
        cpu.step()
        XCTAssertEqual(cpu.mem[0xaaaa], 0xaa)
        XCTAssertEqual(cpu.reg.a, 0x0a)
    }
    func test30_BMI_Relative() {
        cpu.mem[0x8000] = 0x30
        cpu.mem[0x8001] = 0xfe
        cpu.reg.p.n = true
        cpu.step()
        XCTAssertEqual(cpu.reg.pc, 0x8000)
        cpu.reg.p.n = false
        cpu.step()
        XCTAssertEqual(cpu.reg.pc, 0x8002)
    }
    func test31_AND_Indirect_Y() {
        cpu.mem[0x8000] = 0x31
        cpu.mem[0x8001] = 0xdd
        cpu.mem[word: 0x00dd] = 0x7700
        cpu.reg.y = 0x77
        cpu.mem[0x7777] = 0x55
        cpu.reg.a = 0xaa
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x00)
    }
    func test32_STP_Implied() {
        cpu.mem[0x8000] = 0x32
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test33_RLA_Indirect_Y() {
        cpu.mem[0x8000] = 0x33
        cpu.mem[0x8001] = 0xdd
        cpu.mem[word: 0x00dd] = 0x7700
        cpu.reg.y = 0x77
        cpu.mem[0x7777] = 0x55
        cpu.reg.a = 0x0f
        cpu.step()
        XCTAssertEqual(cpu.mem[0x7777], 0xaa)
        XCTAssertEqual(cpu.reg.a, 0x0a)
    }
    func test34_NOP_ZeroPage_X() {
        cpu.mem[0x8000] = 0x34
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test35_AND_ZeroPage_X() {
        cpu.mem[0x8000] = 0x35
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.mem[0x00ee] = 0x55
        cpu.reg.a = 0xaa
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x00)
    }
    func test36_ROL_ZeroPage_X() {
        cpu.mem[0x8000] = 0x36
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.mem[0x00ee] = 0xaa
        cpu.reg.p.c = true
        cpu.step()
        XCTAssertEqual(cpu.mem[0x00ee], 0x55)
        XCTAssertTrue(cpu.reg.p.c)
    }
    func test37_RLA_ZeroPage_X() {
        cpu.mem[0x8000] = 0x37
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.mem[0x00ee] = 0x55
        cpu.reg.a = 0x0f
        cpu.step()
        XCTAssertEqual(cpu.mem[0x00ee], 0xaa)
        XCTAssertEqual(cpu.reg.a, 0x0a)
    }
    func test38_SEC_Implied() {
        cpu.mem[0x8000] = 0x38
        cpu.reg.p.c = false
        cpu.step()
        XCTAssertTrue(cpu.reg.p.c)
    }
    func test39_AND_Absolute_Y() {
        cpu.mem[0x8000] = 0x39
        cpu.mem[word: 0x8001] = 0x7700
        cpu.reg.y = 0x77
        cpu.mem[0x7777] = 0x55
        cpu.reg.a = 0xaa
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x00)
    }
    func test3a_NOP_Implied() {
        cpu.mem[0x8000] = 0x3a
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test3b_RLA_Absolute_Y() {
        cpu.mem[0x8000] = 0x3b
        cpu.mem[word: 0x8001] = 0x7700
        cpu.reg.y = 0x77
        cpu.mem[0x7777] = 0x55
        cpu.reg.a = 0x0f
        cpu.step()
        XCTAssertEqual(cpu.mem[0x7777], 0xaa)
        XCTAssertEqual(cpu.reg.a, 0x0a)
    }
    func test3c_NOP_Absolute_X() {
        cpu.mem[0x8000] = 0x3c
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.reg.x = 0x11
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test3d_AND_Absolute_X() {
        cpu.mem[0x8000] = 0x3d
        cpu.mem[word: 0x8001] = 0x7700
        cpu.reg.x = 0x77
        cpu.mem[0x7777] = 0x55
        cpu.reg.a = 0xaa
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x00)
    }
    func test3e_ROL_Absolute_X() {
        cpu.mem[0x8000] = 0x3e
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.reg.x = 0x11
        cpu.mem[0xaabb] = 0xaa
        cpu.reg.p.c = true
        cpu.step()
        XCTAssertEqual(cpu.mem[0xaabb], 0x55)
        XCTAssertTrue(cpu.reg.p.c)
    }
    func test3f_RLA_Absolute_X() {
        cpu.mem[0x8000] = 0x3f
        cpu.mem[word: 0x8001] = 0x7700
        cpu.reg.x = 0x77
        cpu.mem[0x7777] = 0x55
        cpu.reg.a = 0x0f
        cpu.step()
        XCTAssertEqual(cpu.mem[0x7777], 0xaa)
        XCTAssertEqual(cpu.reg.a, 0x0a)
    }
    func test40_RTI_Implied() {
        cpu.mem[0x8000] = 0x40
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test41_EOR_Indirect_X() {
        cpu.mem[0x8000] = 0x41
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.mem[word: 0x00ee] = 0x0077
        cpu.mem[0x0077] = 0x55
        cpu.reg.a = 0xff
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0xaa)
    }
    func test42_STP_Implied() {
        cpu.mem[0x8000] = 0x42
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test43_SRE_Indirect_X() {
        cpu.mem[0x8000] = 0x43
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test44_NOP_ZeroPage() {
        cpu.mem[0x8000] = 0x44
        cpu.mem[0x8001] = 0xdd
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test45_EOR_ZeroPage() {
        cpu.mem[0x8000] = 0x45
        cpu.mem[0x8001] = 0xdd
        cpu.reg.a = 0xff
        cpu.mem[0x00dd] = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0xaa)
    }
    func test46_LSR_ZeroPage() {
        cpu.mem[0x8000] = 0x46
        cpu.mem[0x8001] = 0xdd
        cpu.mem[0x00dd] = 0xaa
        cpu.step()
        XCTAssertEqual(cpu.mem[0x00dd], 0x55)
    }
    func test47_SRE_ZeroPage() {
        cpu.mem[0x8000] = 0x47
        cpu.mem[0x8001] = 0xdd
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test48_PHA_Implied() {
        cpu.mem[0x8000] = 0x48
        cpu.reg.a = 0x44
        cpu.step()
        XCTAssertEqual(cpu.mem[0x01ff], 0x44)
        XCTAssertEqual(cpu.reg.s, 0xfe)
    }
    func test49_EOR_Immediate() {
        cpu.mem[0x8000] = 0x49
        cpu.mem[0x8001] = 0xaa
        cpu.reg.a = 0xff
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x55)
    }
    func test4a_LSR_Accumulator() {
        cpu.mem[0x8000] = 0x4a
        cpu.reg.a = 0xaa
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x55)
    }
    func test4b_ALR_Immediate() {
        cpu.mem[0x8000] = 0x4b
        cpu.mem[0x8001] = 0xaa
        cpu.reg.a = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x00)
    }
    func test4c_JMP_Absolute() {
        cpu.mem[0x8000] = 0x4c
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.step()
        XCTAssertEqual(cpu.reg.pc, 0xaaaa)
    }
    func test4d_EOR_Absolute() {
        cpu.mem[0x8000] = 0x4d
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.mem[0xaaaa] = 0x55
        cpu.reg.a = 0xff
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0xaa)
    }
    func test4e_LSR_Absolute() {
        cpu.mem[0x8000] = 0x4e
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.mem[0xaaaa] = 0xaa
        cpu.step()
        XCTAssertEqual(cpu.mem[0xaaaa], 0x55)
    }
    func test4f_SRE_Absolute() {
        cpu.mem[0x8000] = 0x4f
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test50_BVC_Relative() {
        cpu.mem[0x8000] = 0x50
        cpu.mem[0x8001] = 0xfe
        cpu.reg.p.v = false
        cpu.step()
        XCTAssertEqual(cpu.reg.pc, 0x8000)
        cpu.reg.p.v = true
        cpu.step()
        XCTAssertEqual(cpu.reg.pc, 0x8002)
    }
    func test51_EOR_Indirect_Y() {
        cpu.mem[0x8000] = 0x51
        cpu.mem[0x8001] = 0xdd
        cpu.mem[word: 0x00dd] = 0x7700
        cpu.reg.y = 0x77
        cpu.mem[0x7777] = 0x55
        cpu.reg.a = 0xff
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0xaa)
    }
    func test52_STP_Implied() {
        cpu.mem[0x8000] = 0x52
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test53_SRE_Indirect_Y() {
        cpu.mem[0x8000] = 0x53
        cpu.mem[0x8001] = 0xdd
        cpu.reg.y = 0x22
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test54_NOP_ZeroPage_X() {
        cpu.mem[0x8000] = 0x54
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test55_EOR_ZeroPage_X() {
        cpu.mem[0x8000] = 0x55
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.mem[0x00ee] = 0x55
        cpu.reg.a = 0xff
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0xaa)
    }
    func test56_LSR_ZeroPage_X() {
        cpu.mem[0x8000] = 0x56
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.mem[0x00ee] = 0xaa
        cpu.step()
        XCTAssertEqual(cpu.mem[0x00ee], 0x55)
    }
    func test57_SRE_ZeroPage_X() {
        cpu.mem[0x8000] = 0x57
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test58_CLI_Implied() {
        cpu.mem[0x8000] = 0x58
        cpu.reg.p.i = true
        cpu.step()
        XCTAssertFalse(cpu.reg.p.i)
    }
    func test59_EOR_Absolute_Y() {
        cpu.mem[0x8000] = 0x59
        cpu.mem[word: 0x8001] = 0x7700
        cpu.reg.y = 0x77
        cpu.mem[0x7777] = 0x55
        cpu.reg.a = 0xff
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0xaa)
    }
    func test5a_NOP_Implied() {
        cpu.mem[0x8000] = 0x5a
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test5b_SRE_Absolute_Y() {
        cpu.mem[0x8000] = 0x5b
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.reg.y = 0x22
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test5c_NOP_Absolute_X() {
        cpu.mem[0x8000] = 0x5c
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.reg.x = 0x11
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test5d_EOR_Absolute_X() {
        cpu.mem[0x8000] = 0x5d
        cpu.mem[word: 0x8001] = 0x7700
        cpu.reg.x = 0x77
        cpu.mem[0x7777] = 0x55
        cpu.reg.a = 0xff
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0xaa)
    }
    func test5e_LSR_Absolute_X() {
        cpu.mem[0x8000] = 0x5e
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.reg.x = 0x11
        cpu.reg.a = 0x33
        cpu.mem[0xaabb] = 0xaa
        cpu.step()
        XCTAssertEqual(cpu.mem[0xaabb], 0x55)
    }
    func test5f_SRE_Absolute_X() {
        cpu.mem[0x8000] = 0x5f
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.reg.x = 0x11
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test60_RTS_Implied() {
        cpu.mem[0x8000] = 0x60
        cpu.reg.s = 0xf0
        cpu.mem[word: 0x01f1] = 0x9999
        cpu.step()
        XCTAssertEqual(cpu.reg.pc, 0x999A)
        XCTAssertEqual(cpu.reg.s, 0xf2)
    }
    func test61_ADC_Indirect_X() {
        cpu.mem[0x8000] = 0x61
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.mem[word: 0x00ee] = 0x0077
        cpu.mem[0x0077] = 12
        cpu.reg.a = 34
        cpu.reg.p.c = true
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 12+34+1)
    }
    func test62_STP_Implied() {
        cpu.mem[0x8000] = 0x62
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test63_RRA_Indirect_X() {
        cpu.mem[0x8000] = 0x63
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test64_NOP_ZeroPage() {
        cpu.mem[0x8000] = 0x64
        cpu.mem[0x8001] = 0xdd
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test65_ADC_ZeroPage() {
        cpu.mem[0x8000] = 0x65
        cpu.mem[0x8001] = 0xdd
        cpu.reg.a = 12
        cpu.mem[0x00dd] = 34
        cpu.reg.p.c = true
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 12+34+1)
    }
    func test66_ROR_ZeroPage() {
        cpu.mem[0x8000] = 0x66
        cpu.mem[0x8001] = 0xdd
        cpu.mem[0x00dd] = 0x55
        cpu.reg.p.c = true
        cpu.step()
        XCTAssertEqual(cpu.mem[0x00dd], 0xaa)
        XCTAssertTrue(cpu.reg.p.c)
    }
    func test67_RRA_ZeroPage() {
        cpu.mem[0x8000] = 0x67
        cpu.mem[0x8001] = 0xdd
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test68_PLA_Implied() {
        cpu.mem[0x8000] = 0x68
        cpu.reg.s = 0xfe
        cpu.mem[0x01ff] = 0x44
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x44)
        XCTAssertEqual(cpu.reg.s, 0xff)
    }
    func test69_ADC_Immediate() {
        cpu.mem[0x8000] = 0x69
        cpu.mem[0x8001] = 34
        cpu.reg.a = 12
        cpu.reg.p.c = true
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 12+34+1)
    }
    func test6a_ROR_Accumulator() {
        cpu.mem[0x8000] = 0x6a
        cpu.reg.a = 0x55
        cpu.reg.p.c = true
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0xaa)
        XCTAssertTrue(cpu.reg.p.c)
    }
    func test6b_ARR_Immediate() {
        cpu.mem[0x8000] = 0x6b
        cpu.mem[0x8001] = 0xaa
        cpu.reg.a = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x00)
    }
    func test6c_JMP_Indirect() {
        cpu.mem[0x8000] = 0x6c
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.mem[word: 0xaaaa] = 0xbbbb
        cpu.step()
        XCTAssertEqual(cpu.reg.pc, 0xbbbb)
    }
    func test6d_ADC_Absolute() {
        cpu.mem[0x8000] = 0x6d
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.mem[0xaaaa] = 12
        cpu.reg.a = 34
        cpu.reg.p.c = true
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 12+34+1)
    }
    func test6e_ROR_Absolute() {
        cpu.mem[0x8000] = 0x6e
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.mem[0xaaaa] = 0x55
        cpu.reg.p.c = true
        cpu.step()
        XCTAssertEqual(cpu.mem[0xaaaa], 0xaa)
        XCTAssertTrue(cpu.reg.p.c)
    }
    func test6f_RRA_Absolute() {
        cpu.mem[0x8000] = 0x6f
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test70_BVS_Relative() {
        cpu.mem[0x8000] = 0x70
        cpu.mem[0x8001] = 0xfe
        cpu.reg.p.v = true
        cpu.step()
        XCTAssertEqual(cpu.reg.pc, 0x8000)
        cpu.reg.p.v = false
        cpu.step()
        XCTAssertEqual(cpu.reg.pc, 0x8002)
    }
    func test71_ADC_Indirect_Y() {
        cpu.mem[0x8000] = 0x71
        cpu.mem[0x8001] = 0xdd
        cpu.mem[word: 0x00dd] = 0x7700
        cpu.reg.y = 0x77
        cpu.mem[0x7777] = 12
        cpu.reg.a = 34
        cpu.reg.p.c = true
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 12+34+1)
    }
    func test72_STP_Implied() {
        cpu.mem[0x8000] = 0x72
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test73_RRA_Indirect_Y() {
        cpu.mem[0x8000] = 0x73
        cpu.mem[0x8001] = 0xdd
        cpu.reg.y = 0x22
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test74_NOP_ZeroPage_X() {
        cpu.mem[0x8000] = 0x74
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test75_ADC_ZeroPage_X() {
        cpu.mem[0x8000] = 0x75
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.mem[0x00ee] = 12
        cpu.reg.a = 34
        cpu.reg.p.c = true
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 12+34+1)
    }
    func test76_ROR_ZeroPage_X() {
        cpu.mem[0x8000] = 0x76
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.mem[0x00ee] = 0x55
        cpu.reg.p.c = true
        cpu.step()
        XCTAssertEqual(cpu.mem[0x00ee], 0xaa)
        XCTAssertTrue(cpu.reg.p.c)
    }
    func test77_RRA_ZeroPage_X() {
        cpu.mem[0x8000] = 0x77
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test78_SEI_Implied() {
        cpu.mem[0x8000] = 0x78
        cpu.reg.p.i = false
        cpu.step()
        XCTAssertTrue(cpu.reg.p.i)
    }
    func test79_ADC_Absolute_Y() {
        cpu.mem[0x8000] = 0x79
        cpu.mem[word: 0x8001] = 0x7700
        cpu.reg.y = 0x77
        cpu.mem[0x7777] = 12
        cpu.reg.a = 34
        cpu.reg.p.c = true
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 12+34+1)
    }
    func test7a_NOP_Implied() {
        cpu.mem[0x8000] = 0x7a
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test7b_RRA_Absolute_Y() {
        cpu.mem[0x8000] = 0x7b
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.reg.y = 0x22
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test7c_NOP_Absolute_X() {
        cpu.mem[0x8000] = 0x7c
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.reg.x = 0x11
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test7d_ADC_Absolute_X() {
        cpu.mem[0x8000] = 0x7d
        cpu.mem[word: 0x8001] = 0x7700
        cpu.reg.x = 0x77
        cpu.mem[0x7777] = 12
        cpu.reg.a = 34
        cpu.reg.p.c = true
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 12+34+1)
    }
    func test7e_ROR_Absolute_X() {
        cpu.mem[0x8000] = 0x7e
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.reg.x = 0x11
        cpu.mem[0xaabb] = 0x55
        cpu.reg.p.c = true
        cpu.step()
        XCTAssertEqual(cpu.mem[0xaabb], 0xaa)
        XCTAssertTrue(cpu.reg.p.c)
    }
    func test7f_RRA_Absolute_X() {
        cpu.mem[0x8000] = 0x7f
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.reg.x = 0x11
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test80_NOP_Immediate() {
        cpu.mem[0x8000] = 0x80
        cpu.mem[0x8001] = 0xdd
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test81_STA_Indirect_X() {
        cpu.mem[0x8000] = 0x81
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.mem[word: 0x00ee] = 0x0077
        cpu.reg.a = 0x55
        cpu.step()
        XCTAssertEqual(cpu.mem[0x0077], 0x55)
    }
    func test82_NOP_Immediate() {
        cpu.mem[0x8000] = 0x82
        cpu.mem[0x8001] = 0xdd
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test83_SAX_Indirect_X() {
        cpu.mem[0x8000] = 0x83
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test84_STY_ZeroPage() {
        cpu.mem[0x8000] = 0x84
        cpu.mem[0x8001] = 0xdd
        cpu.reg.y = 0x55
        cpu.step()
        XCTAssertEqual(cpu.mem[0x00dd], 0x55)
    }
    func test85_STA_ZeroPage() {
        cpu.mem[0x8000] = 0x85
        cpu.mem[0x8001] = 0xdd
        cpu.reg.a = 0x55
        cpu.step()
        XCTAssertEqual(cpu.mem[0x00dd], 0x55)
    }
    func test86_STX_ZeroPage() {
        cpu.mem[0x8000] = 0x86
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x55
        cpu.step()
        XCTAssertEqual(cpu.mem[0x00dd], 0x55)
    }
    func test87_SAX_ZeroPage() {
        cpu.mem[0x8000] = 0x87
        cpu.mem[0x8001] = 0xdd
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test88_DEY_Implied() {
        cpu.mem[0x8000] = 0x88
        cpu.reg.y = 1
        cpu.step()
        XCTAssertEqual(cpu.reg.y, 0)
        XCTAssertFalse(cpu.reg.p.n)
        XCTAssertTrue(cpu.reg.p.z)
    }
    func test89_NOP_Immediate() {
        cpu.mem[0x8000] = 0x89
        cpu.mem[0x8001] = 0xdd
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test8a_TXA_Implied() {
        cpu.mem[0x8000] = 0x8a
        cpu.reg.x = 123
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 123)
    }
    func test8b_XAA_Immediate() {
        cpu.mem[0x8000] = 0x8b
        cpu.mem[0x8001] = 0xaa
        cpu.reg.a = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x00)
    }
    func test8c_STY_Absolute() {
        cpu.mem[0x8000] = 0x8c
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.reg.y = 0x55
        cpu.step()
        XCTAssertEqual(cpu.mem[0xaaaa], 0x55)
    }
    func test8d_STA_Absolute() {
        cpu.mem[0x8000] = 0x8d
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.reg.a = 0x55
        cpu.step()
        XCTAssertEqual(cpu.mem[0xaaaa], 0x55)
    }
    func test8e_STX_Absolute() {
        cpu.mem[0x8000] = 0x8e
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.reg.x = 0x55
        cpu.step()
        XCTAssertEqual(cpu.mem[0xaaaa], 0x55)
    }
    func test8f_SAX_Absolute() {
        cpu.mem[0x8000] = 0x8f
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test90_BCC_Relative() {
        cpu.mem[0x8000] = 0x90
        cpu.mem[0x8001] = 0xfe
        cpu.reg.p.c = false
        cpu.step()
        XCTAssertEqual(cpu.reg.pc, 0x8000)
        cpu.reg.p.c = true
        cpu.step()
        XCTAssertEqual(cpu.reg.pc, 0x8002)
    }
    func test91_STA_Indirect_Y() {
        cpu.mem[0x8000] = 0x91
        cpu.mem[0x8001] = 0xdd
        cpu.mem[word: 0x00dd] = 0x7700
        cpu.reg.y = 0x77
        cpu.reg.a = 0x55
        cpu.step()
        XCTAssertEqual(cpu.mem[0x7777], 0x55)
    }
    func test92_STP_Implied() {
        cpu.mem[0x8000] = 0x92
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test93_AHX_Indirect_Y() {
        cpu.mem[0x8000] = 0x93
        cpu.mem[0x8001] = 0xdd
        cpu.reg.y = 0x22
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test94_STY_ZeroPage_X() {
        cpu.mem[0x8000] = 0x94
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.reg.y = 0x55
        cpu.step()
        XCTAssertEqual(cpu.mem[0x00ee], 0x55)
    }
    func test95_STA_ZeroPage_X() {
        cpu.mem[0x8000] = 0x95
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.reg.a = 0x55
        cpu.step()
        XCTAssertEqual(cpu.mem[0x00ee], 0x55)
    }
    func test96_STX_ZeroPage_Y() {
        cpu.mem[0x8000] = 0x96
        cpu.mem[0x8001] = 0xdd
        cpu.reg.y = 0x11
        cpu.reg.x = 0x55
        cpu.step()
        XCTAssertEqual(cpu.mem[0x00ee], 0x55)
    }
    func test97_SAX_ZeroPage_Y() {
        cpu.mem[0x8000] = 0x97
        cpu.mem[0x8001] = 0xdd
        cpu.reg.y = 0x22
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test98_TYA_Implied() {
        cpu.mem[0x8000] = 0x98
        cpu.reg.y = 123
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 123)
    }
    func test99_STA_Absolute_Y() {
        cpu.mem[0x8000] = 0x99
        cpu.mem[word: 0x8001] = 0x7700
        cpu.reg.y = 0x77
        cpu.reg.a = 0x55
        cpu.step()
        XCTAssertEqual(cpu.mem[0x7777], 0x55)
    }
    func test9a_TXS_Implied() {
        cpu.mem[0x8000] = 0x9a
        cpu.reg.x = 123
        cpu.step()
        XCTAssertEqual(cpu.reg.s, 123)
    }
    func test9b_TAS_Absolute_Y() {
        cpu.mem[0x8000] = 0x9b
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.reg.y = 0x22
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test9c_SHY_Absolute_X() {
        cpu.mem[0x8000] = 0x9c
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.reg.x = 0x11
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test9d_STA_Absolute_X() {
        cpu.mem[0x8000] = 0x9d
        cpu.mem[word: 0x8001] = 0x7700
        cpu.reg.x = 0x77
        cpu.reg.a = 0x55
        cpu.step()
        XCTAssertEqual(cpu.mem[0x7777], 0x55)
    }
    func test9e_SHX_Absolute_Y() {
        cpu.mem[0x8000] = 0x9e
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.reg.y = 0x22
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func test9f_AHX_Absolute_Y() {
        cpu.mem[0x8000] = 0x9f
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.reg.y = 0x22
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func testa0_LDY_Immediate() {
        cpu.mem[0x8000] = 0xa0
        cpu.mem[0x8001] = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.y, 0x55)
    }
    func testa1_LDA_Indirect_X() {
        cpu.mem[0x8000] = 0xa1
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.mem[word: 0x00ee] = 0x0077
        cpu.mem[0x0077] = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x55)
    }
    func testa2_LDX_Immediate() {
        cpu.mem[0x8000] = 0xa2
        cpu.mem[0x8001] = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.x, 0x55)
    }
    func testa3_LAX_Indirect_X() {
        cpu.mem[0x8000] = 0xa3
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.mem[word: 0x00ee] = 0x0077
        cpu.mem[0x0077] = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x55)
        XCTAssertEqual(cpu.reg.x, 0x55)
    }
    func testa4_LDY_ZeroPage() {
        cpu.mem[0x8000] = 0xa4
        cpu.mem[0x8001] = 0xdd
        cpu.mem[0x00dd] = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.y, 0x55)
    }
    func testa5_LDA_ZeroPage() {
        cpu.mem[0x8000] = 0xa5
        cpu.mem[0x8001] = 0xdd
        cpu.mem[0x00dd] = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x55)
    }
    func testa6_LDX_ZeroPage() {
        cpu.mem[0x8000] = 0xa6
        cpu.mem[0x8001] = 0xdd
        cpu.mem[0x00dd] = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.x, 0x55)
    }
    func testa7_LAX_ZeroPage() {
        cpu.mem[0x8000] = 0xa7
        cpu.mem[0x8001] = 0xdd
        cpu.mem[0x00dd] = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x55)
        XCTAssertEqual(cpu.reg.x, 0x55)
    }
    func testa8_TAY_Implied() {
        cpu.mem[0x8000] = 0xa8
        cpu.reg.a = 123
        cpu.step()
        XCTAssertEqual(cpu.reg.y, 123)
    }
    func testa9_LDA_Immediate() {
        cpu.mem[0x8000] = 0xa9
        cpu.mem[0x8001] = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x55)
    }
    func testaa_TAX_Implied() {
        cpu.mem[0x8000] = 0xaa
        cpu.reg.a = 123
        cpu.step()
        XCTAssertEqual(cpu.reg.x, 123)
    }
    func testab_LAX_Immediate() {
        cpu.mem[0x8000] = 0xab
        cpu.mem[0x8001] = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x55)
        XCTAssertEqual(cpu.reg.x, 0x55)
    }
    func testac_LDY_Absolute() {
        cpu.mem[0x8000] = 0xac
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.mem[0xaaaa] = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.y, 0x55)
    }
    func testad_LDA_Absolute() {
        cpu.mem[0x8000] = 0xad
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.mem[0xaaaa] = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x55)
    }
    func testae_LDX_Absolute() {
        cpu.mem[0x8000] = 0xae
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.mem[0xaaaa] = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.x, 0x55)
    }
    func testaf_LAX_Absolute() {
        cpu.mem[0x8000] = 0xaf
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.mem[0xaaaa] = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x55)
        XCTAssertEqual(cpu.reg.x, 0x55)
    }
    func testb0_BCS_Relative() {
        cpu.mem[0x8000] = 0xb0
        cpu.mem[0x8001] = 0xfe
        cpu.reg.p.c = true
        cpu.step()
        XCTAssertEqual(cpu.reg.pc, 0x8000)
        cpu.reg.p.c = false
        cpu.step()
        XCTAssertEqual(cpu.reg.pc, 0x8002)
    }
    func testb1_LDA_Indirect_Y() {
        cpu.mem[0x8000] = 0xb1
        cpu.mem[0x8001] = 0xdd
        cpu.mem[word: 0x00dd] = 0x7700
        cpu.reg.y = 0x77
        cpu.mem[0x7777] = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x55)
    }
    func testb2_STP_Implied() {
        cpu.mem[0x8000] = 0xb2
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func testb3_LAX_Indirect_Y() {
        cpu.mem[0x8000] = 0xb3
        cpu.mem[0x8001] = 0xdd
        cpu.mem[word: 0x00dd] = 0x7700
        cpu.reg.y = 0x77
        cpu.mem[0x7777] = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x55)
        XCTAssertEqual(cpu.reg.x, 0x55)
    }
    func testb4_LDY_ZeroPage_X() {
        cpu.mem[0x8000] = 0xb4
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.mem[0x00ee] = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.y, 0x55)
    }
    func testb5_LDA_ZeroPage_X() {
        cpu.mem[0x8000] = 0xb5
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.mem[0x00ee] = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x55)
    }
    func testb6_LDX_ZeroPage_Y() {
        cpu.mem[0x8000] = 0xb6
        cpu.mem[0x8001] = 0xdd
        cpu.reg.y = 0x11
        cpu.mem[0x00ee] = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.x, 0x55)
    }
    func testb7_LAX_ZeroPage_Y() {
        cpu.mem[0x8000] = 0xb7
        cpu.mem[0x8001] = 0xdd
        cpu.reg.y = 0x11
        cpu.mem[0x00ee] = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x55)
        XCTAssertEqual(cpu.reg.x, 0x55)
    }
    func testb8_CLV_Implied() {
        cpu.mem[0x8000] = 0xb8
        cpu.reg.p.v = true
        cpu.step()
        XCTAssertFalse(cpu.reg.p.v)
    }
    func testb9_LDA_Absolute_Y() {
        cpu.mem[0x8000] = 0xb9
        cpu.mem[word: 0x8001] = 0x7700
        cpu.reg.y = 0x77
        cpu.mem[0x7777] = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x55)
    }
    func testba_TSX_Implied() {
        cpu.mem[0x8000] = 0xba
        cpu.reg.s = 123
        cpu.step()
        XCTAssertEqual(cpu.reg.x, 123)
    }
    func testbb_LAS_Absolute_Y() {
        cpu.mem[0x8000] = 0xbb
        cpu.mem[word: 0x8001] = 0x7700
        cpu.reg.y = 0x77
        cpu.mem[0x7777] = 0x0f
        cpu.reg.s = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x05)
        XCTAssertEqual(cpu.reg.x, 0x05)
        XCTAssertEqual(cpu.reg.s, 0x05)
    }
    func testbc_LDY_Absolute_X() {
        cpu.mem[0x8000] = 0xbc
        cpu.mem[word: 0x8001] = 0x7700
        cpu.reg.x = 0x77
        cpu.mem[0x7777] = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.y, 0x55)
    }
    func testbd_LDA_Absolute_X() {
        cpu.mem[0x8000] = 0xbd
        cpu.mem[word: 0x8001] = 0x7700
        cpu.reg.x = 0x77
        cpu.mem[0x7777] = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x55)
    }
    func testbe_LDX_Absolute_Y() {
        cpu.mem[0x8000] = 0xbe
        cpu.mem[word: 0x8001] = 0x7700
        cpu.reg.y = 0x77
        cpu.mem[0x7777] = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.x, 0x55)
    }
    func testbf_LAX_Absolute_Y() {
        cpu.mem[0x8000] = 0xbf
        cpu.mem[word: 0x8001] = 0x7700
        cpu.reg.y = 0x77
        cpu.mem[0x7777] = 0x55
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x55)
        XCTAssertEqual(cpu.reg.x, 0x55)
    }
    func testc0_CPY_Immediate() {
        cpu.mem[0x8000] = 0xc0
        cpu.mem[0x8001] = 2
        cpu.reg.y = 1
        cpu.step()
        XCTAssertTrue(cpu.reg.p.n)
        XCTAssertFalse(cpu.reg.p.z)
        XCTAssertFalse(cpu.reg.p.c)
    }
    func testc1_CMP_Indirect_X() {
        cpu.mem[0x8000] = 0xc1
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.mem[word: 0x00ee] = 0x0077
        cpu.mem[0x0077] = 2
        cpu.reg.a = 1
        cpu.step()
        XCTAssertTrue(cpu.reg.p.n)
        XCTAssertFalse(cpu.reg.p.z)
        XCTAssertFalse(cpu.reg.p.c)
    }
    func testc2_NOP_Immediate() {
        cpu.mem[0x8000] = 0xc2
        cpu.mem[0x8001] = 0xdd
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func testc3_DCP_Indirect_X() {
        cpu.mem[0x8000] = 0xc3
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func testc4_CPY_ZeroPage() {
        cpu.mem[0x8000] = 0xc4
        cpu.mem[0x8001] = 0xdd
        cpu.mem[0x00dd] = 2
        cpu.reg.x = 1
        cpu.step()
        XCTAssertTrue(cpu.reg.p.n)
        XCTAssertFalse(cpu.reg.p.z)
        XCTAssertFalse(cpu.reg.p.c)
    }
    func testc5_CMP_ZeroPage() {
        cpu.mem[0x8000] = 0xc5
        cpu.mem[0x8001] = 0xdd
        cpu.reg.a = 1
        cpu.mem[0x00dd] = 2
        cpu.step()
        XCTAssertTrue(cpu.reg.p.n)
        XCTAssertFalse(cpu.reg.p.z)
        XCTAssertFalse(cpu.reg.p.c)
    }
    func testc6_DEC_ZeroPage() {
        cpu.mem[0x8000] = 0xc6
        cpu.mem[0x8001] = 0xdd
        cpu.mem[0x00dd] = 1
        cpu.step()
        XCTAssertEqual(cpu.mem[0x00dd], 0)
        XCTAssertFalse(cpu.reg.p.n)
        XCTAssertTrue(cpu.reg.p.z)
    }
    func testc7_DCP_ZeroPage() {
        cpu.mem[0x8000] = 0xc7
        cpu.mem[0x8001] = 0xdd
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func testc8_INY_Implied() {
        cpu.mem[0x8000] = 0xc8
        cpu.reg.y = 0x7f
        cpu.step()
        XCTAssertEqual(cpu.reg.y, 0x80)
        XCTAssertTrue(cpu.reg.p.n)
        XCTAssertFalse(cpu.reg.p.z)
    }
    func testc9_CMP_Immediate() {
        cpu.mem[0x8000] = 0xc9
        cpu.mem[0x8001] = 2
        cpu.reg.a = 1
        cpu.step()
        XCTAssertTrue(cpu.reg.p.n)
        XCTAssertFalse(cpu.reg.p.z)
        XCTAssertFalse(cpu.reg.p.c)
    }
    func testca_DEX_Implied() {
        cpu.mem[0x8000] = 0xca
        cpu.reg.x = 1
        cpu.step()
        XCTAssertEqual(cpu.reg.x, 0)
        XCTAssertFalse(cpu.reg.p.n)
        XCTAssertTrue(cpu.reg.p.z)
    }
    func testcb_AXS_Immediate() {
        cpu.mem[0x8000] = 0xcb
        cpu.mem[0x8001] = 0xdd
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func testcc_CPY_Absolute() {
        cpu.mem[0x8000] = 0xcc
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.mem[0xaaaa] = 2
        cpu.reg.x = 1
        cpu.step()
        XCTAssertTrue(cpu.reg.p.n)
        XCTAssertFalse(cpu.reg.p.z)
        XCTAssertFalse(cpu.reg.p.c)
    }
    func testcd_CMP_Absolute() {
        cpu.mem[0x8000] = 0xcd
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.mem[0xaaaa] = 2
        cpu.reg.a = 1
        cpu.step()
        XCTAssertTrue(cpu.reg.p.n)
        XCTAssertFalse(cpu.reg.p.z)
        XCTAssertFalse(cpu.reg.p.c)
    }
    func testce_DEC_Absolute() {
        cpu.mem[0x8000] = 0xce
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.mem[0xaaaa] = 1
        cpu.step()
        XCTAssertEqual(cpu.mem[0xaaaa], 0)
        XCTAssertFalse(cpu.reg.p.n)
        XCTAssertTrue(cpu.reg.p.z)
    }
    func testcf_DCP_Absolute() {
        cpu.mem[0x8000] = 0xcf
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func testd0_BNE_Relative() {
        cpu.mem[0x8000] = 0xd0
        cpu.mem[0x8001] = 0xfe
        cpu.reg.p.z = false
        cpu.step()
        XCTAssertEqual(cpu.reg.pc, 0x8000)
        cpu.reg.p.z = true
        cpu.step()
        XCTAssertEqual(cpu.reg.pc, 0x8002)
    }
    func testd1_CMP_Indirect_Y() {
        cpu.mem[0x8000] = 0xd1
        cpu.mem[0x8001] = 0xdd
        cpu.mem[word: 0x00dd] = 0x7700
        cpu.reg.y = 0x77
        cpu.mem[0x7777] = 2
        cpu.reg.a = 1
        cpu.step()
        XCTAssertTrue(cpu.reg.p.n)
        XCTAssertFalse(cpu.reg.p.z)
        XCTAssertFalse(cpu.reg.p.c)
    }
    func testd2_STP_Implied() {
        cpu.mem[0x8000] = 0xd2
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func testd3_DCP_Indirect_Y() {
        cpu.mem[0x8000] = 0xd3
        cpu.mem[0x8001] = 0xdd
        cpu.reg.y = 0x22
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func testd4_NOP_ZeroPage_X() {
        cpu.mem[0x8000] = 0xd4
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func testd5_CMP_ZeroPage_X() {
        cpu.mem[0x8000] = 0xd5
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.mem[0x00ee] = 2
        cpu.reg.a = 1
        cpu.step()
        XCTAssertTrue(cpu.reg.p.n)
        XCTAssertFalse(cpu.reg.p.z)
        XCTAssertFalse(cpu.reg.p.c)
    }
    func testd6_DEC_ZeroPage_X() {
        cpu.mem[0x8000] = 0xd6
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.mem[0x00ee] = 1
        cpu.step()
        XCTAssertEqual(cpu.mem[0x00ee], 0)
        XCTAssertFalse(cpu.reg.p.n)
        XCTAssertTrue(cpu.reg.p.z)
    }
    func testd7_DCP_ZeroPage_X() {
        cpu.mem[0x8000] = 0xd7
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func testd8_CLD_Implied() {
        cpu.mem[0x8000] = 0xd8
        cpu.reg.p.d = true
        cpu.step()
        XCTAssertFalse(cpu.reg.p.d)
    }
    func testd9_CMP_Absolute_Y() {
        cpu.mem[0x8000] = 0xd9
        cpu.mem[word: 0x8001] = 0x7700
        cpu.reg.y = 0x77
        cpu.mem[0x7777] = 2
        cpu.reg.a = 1
        cpu.step()
        XCTAssertTrue(cpu.reg.p.n)
        XCTAssertFalse(cpu.reg.p.z)
        XCTAssertFalse(cpu.reg.p.c)
    }
    func testda_NOP_Implied() {
        cpu.mem[0x8000] = 0xda
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func testdb_DCP_Absolute_Y() {
        cpu.mem[0x8000] = 0xdb
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.reg.y = 0x22
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func testdc_NOP_Absolute_X() {
        cpu.mem[0x8000] = 0xdc
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.reg.x = 0x11
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func testdd_CMP_Absolute_X() {
        cpu.mem[0x8000] = 0xdd
        cpu.mem[word: 0x8001] = 0x7700
        cpu.reg.x = 0x77
        cpu.mem[0x7777] = 2
        cpu.reg.a = 1
        cpu.step()
        XCTAssertTrue(cpu.reg.p.n)
        XCTAssertFalse(cpu.reg.p.z)
        XCTAssertFalse(cpu.reg.p.c)
    }
    func testde_DEC_Absolute_X() {
        cpu.mem[0x8000] = 0xde
        cpu.mem[word: 0x8001] = 0x7700
        cpu.reg.x = 0x77
        cpu.mem[0x7777] = 1
        cpu.step()
        XCTAssertEqual(cpu.mem[0x7777], 0)
        XCTAssertFalse(cpu.reg.p.n)
        XCTAssertTrue(cpu.reg.p.z)
    }
    func testdf_DCP_Absolute_X() {
        cpu.mem[0x8000] = 0xdf
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.reg.x = 0x11
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func teste0_CPX_Immediate() {
        cpu.mem[0x8000] = 0xe0
        cpu.mem[0x8001] = 2
        cpu.reg.x = 1
        cpu.step()
        XCTAssertTrue(cpu.reg.p.n)
        XCTAssertFalse(cpu.reg.p.z)
        XCTAssertFalse(cpu.reg.p.c)
    }
    func teste1_SBC_Indirect_X() {
        cpu.mem[0x8000] = 0xe1
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.mem[word: 0x00ee] = 0x0077
        cpu.mem[0x0077] = 34
        cpu.reg.a = 56
        cpu.reg.p.c = false
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 56-34-1)
    }
    func teste2_NOP_Immediate() {
        cpu.mem[0x8000] = 0xe2
        cpu.mem[0x8001] = 0xdd
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func teste3_ISC_Indirect_X() {
        cpu.mem[0x8000] = 0xe3
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.mem[word: 0x00ee] = 0x0077
        cpu.mem[0x0077] = 34
        cpu.reg.a = 56
        cpu.step()
        XCTAssertEqual(cpu.mem[0x0077], 35)
        XCTAssertEqual(cpu.reg.a, 56-35-1)
    }
    func teste4_CPX_ZeroPage() {
        cpu.mem[0x8000] = 0xe4
        cpu.mem[0x8001] = 0xdd
        cpu.mem[0x00dd] = 2
        cpu.reg.x = 1
        cpu.step()
        XCTAssertTrue(cpu.reg.p.n)
        XCTAssertFalse(cpu.reg.p.z)
        XCTAssertFalse(cpu.reg.p.c)
    }
    func teste5_SBC_ZeroPage() {
        cpu.mem[0x8000] = 0xe5
        cpu.mem[0x8001] = 0xdd
        cpu.reg.a = 56
        cpu.mem[0x00dd] = 34
        cpu.reg.p.c = false
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 56-34-1)
    }
    func teste6_INC_ZeroPage() {
        cpu.mem[0x8000] = 0xe6
        cpu.mem[0x8001] = 0xdd
        cpu.mem[0x00dd] = 0x7f
        cpu.step()
        XCTAssertEqual(cpu.mem[0x00dd], 0x80)
        XCTAssertTrue(cpu.reg.p.n)
        XCTAssertFalse(cpu.reg.p.z)
    }
    func teste7_ISC_ZeroPage() {
        cpu.mem[0x8000] = 0xe7
        cpu.mem[0x8001] = 0xdd
        cpu.mem[0x00dd] = 34
        cpu.reg.a = 56
        cpu.step()
        XCTAssertEqual(cpu.mem[0x00dd], 35)
        XCTAssertEqual(cpu.reg.a, 56-35-1)
    }
    func teste8_INX_Implied() {
        cpu.mem[0x8000] = 0xe8
        cpu.reg.x = 0x7f
        cpu.step()
        XCTAssertEqual(cpu.reg.x, 0x80)
        XCTAssertTrue(cpu.reg.p.n)
        XCTAssertFalse(cpu.reg.p.z)
    }
    func teste9_SBC_Immediate() {
        cpu.mem[0x8000] = 0xe9
        cpu.mem[0x8001] = 34
        cpu.reg.a = 56
        cpu.reg.p.c = false
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 56-34-1)
    }
    func testea_NOP_Implied() {
        cpu.mem[0x8000] = 0xea
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func testeb_SBC_Immediate() {
        cpu.mem[0x8000] = 0xeb
        cpu.mem[0x8001] = 34
        cpu.reg.a = 56
        cpu.reg.p.c = false
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 56-34-1)
    }
    func testec_CPX_Absolute() {
        cpu.mem[0x8000] = 0xec
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.mem[0xaaaa] = 2
        cpu.reg.x = 1
        cpu.step()
        XCTAssertTrue(cpu.reg.p.n)
        XCTAssertFalse(cpu.reg.p.z)
        XCTAssertFalse(cpu.reg.p.c)
    }
    func tested_SBC_Absolute() {
        cpu.mem[0x8000] = 0xed
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.mem[0xaaaa] = 34
        cpu.reg.a = 56
        cpu.reg.p.c = false
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 56-34-1)
    }
    func testee_INC_Absolute() {
        cpu.mem[0x8000] = 0xee
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.mem[0xaaaa] = 0x7f
        cpu.step()
        XCTAssertEqual(cpu.mem[0xaaaa], 0x80)
        XCTAssertTrue(cpu.reg.p.n)
        XCTAssertFalse(cpu.reg.p.z)
    }
    func testef_ISC_Absolute() {
        cpu.mem[0x8000] = 0xef
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.mem[0xaaaa] = 34
        cpu.reg.a = 56
        cpu.step()
        XCTAssertEqual(cpu.mem[0xaaaa], 35)
        XCTAssertEqual(cpu.reg.a, 56-35-1)
    }
    func testf0_BEQ_Relative() {
        cpu.mem[0x8000] = 0xf0
        cpu.mem[0x8001] = 0xfe
        cpu.reg.p.z = true
        cpu.step()
        XCTAssertEqual(cpu.reg.pc, 0x8000)
        cpu.reg.p.z = false
        cpu.step()
        XCTAssertEqual(cpu.reg.pc, 0x8002)
    }
    func testf1_SBC_Indirect_Y() {
        cpu.mem[0x8000] = 0xf1
        cpu.mem[0x8001] = 0xdd
        cpu.mem[word: 0x00dd] = 0x7700
        cpu.reg.y = 0x77
        cpu.mem[0x7777] = 34
        cpu.reg.a = 56
        cpu.reg.p.c = false
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 56-34-1)
    }
    func testf2_STP_Implied() {
        cpu.mem[0x8000] = 0xf2
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func testf3_ISC_Indirect_Y() {
        cpu.mem[0x8000] = 0xf3
        cpu.mem[0x8001] = 0xdd
        cpu.mem[word: 0x00dd] = 0x7700
        cpu.reg.y = 0x77
        cpu.mem[0x7777] = 34
        cpu.reg.a = 56
        cpu.step()
        XCTAssertEqual(cpu.mem[0x7777], 35)
        XCTAssertEqual(cpu.reg.a, 56-35-1)
    }
    func testf4_NOP_ZeroPage_X() {
        cpu.mem[0x8000] = 0xf4
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func testf5_SBC_ZeroPage_X() {
        cpu.mem[0x8000] = 0xf5
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.mem[0x00ee] = 34
        cpu.reg.a = 56
        cpu.reg.p.c = false
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 56-34-1)
    }
    func testf6_INC_ZeroPage_X() {
        cpu.mem[0x8000] = 0xf6
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.mem[0x00ee] = 0x7f
        cpu.step()
        XCTAssertEqual(cpu.mem[0x00ee], 0x80)
        XCTAssertTrue(cpu.reg.p.n)
        XCTAssertFalse(cpu.reg.p.z)
    }
    func testf7_ISC_ZeroPage_X() {
        cpu.mem[0x8000] = 0xf7
        cpu.mem[0x8001] = 0xdd
        cpu.reg.x = 0x11
        cpu.mem[0x00ee] = 34
        cpu.reg.a = 56
        cpu.step()
        XCTAssertEqual(cpu.mem[0x00ee], 35)
        XCTAssertEqual(cpu.reg.a, 56-35-1)
    }
    func testf8_SED_Implied() {
        cpu.mem[0x8000] = 0xf8
        cpu.reg.p.d = false
        cpu.step()
        XCTAssertTrue(cpu.reg.p.d)
    }
    func testf9_SBC_Absolute_Y() {
        cpu.mem[0x8000] = 0xf9
        cpu.mem[word: 0x8001] = 0x7700
        cpu.reg.y = 0x77
        cpu.mem[0x7777] = 34
        cpu.reg.a = 56
        cpu.reg.p.c = false
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 56-34-1)
    }
    func testfa_NOP_Implied() {
        cpu.mem[0x8000] = 0xfa
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func testfb_ISC_Absolute_Y() {
        cpu.mem[0x8000] = 0xfb
        cpu.mem[word: 0x8001] = 0x7700
        cpu.reg.y = 0x77
        cpu.mem[0x7777] = 34
        cpu.reg.a = 56
        cpu.step()
        XCTAssertEqual(cpu.mem[0x7777], 35)
        XCTAssertEqual(cpu.reg.a, 56-35-1)
    }
    func testfc_NOP_Absolute_X() {
        cpu.mem[0x8000] = 0xfc
        cpu.mem[word: 0x8001] = 0xaaaa
        cpu.reg.x = 0x11
        cpu.reg.a = 0x33
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 0x33)
    }
    func testfd_SBC_Absolute_X() {
        cpu.mem[0x8000] = 0xfd
        cpu.mem[word: 0x8001] = 0x7700
        cpu.reg.x = 0x77
        cpu.mem[0x7777] = 34
        cpu.reg.a = 56
        cpu.reg.p.c = false
        cpu.step()
        XCTAssertEqual(cpu.reg.a, 56-34-1)
    }
    func testfe_INC_Absolute_X() {
        cpu.mem[0x8000] = 0xfe
        cpu.mem[word: 0x8001] = 0x7700
        cpu.reg.x = 0x77
        cpu.mem[0x7777] = 0x7f
        cpu.step()
        XCTAssertEqual(cpu.mem[0x7777], 0x80)
        XCTAssertTrue(cpu.reg.p.n)
        XCTAssertFalse(cpu.reg.p.z)
    }
    func testff_ISC_Absolute_X() {
        cpu.mem[0x8000] = 0xff
        cpu.mem[word: 0x8001] = 0x7700
        cpu.reg.x = 0x77
        cpu.mem[0x7777] = 34
        cpu.reg.a = 56
        cpu.step()
        XCTAssertEqual(cpu.mem[0x7777], 35)
        XCTAssertEqual(cpu.reg.a, 56-35-1)
    }
}

extension CPU {
    func step() {
        let opcode = fetch()
        let inst = decode(opcode: opcode)
        let ctx = context(inst: inst)
        exec(context: ctx)
    }
}
