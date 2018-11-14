//
//  RegisterTests.swift
//  NESwftTests
//
//  Created by HIROTA Ichiro on 2018/10/25.
//  Copyright © 2018 HIROTA Ichiro. All rights reserved.
//

import XCTest
@testable import NESwft

class RegisterTests: XCTestCase {

    func testP() {
        var p = Register.P(rawValue: 0)
        p.n = true
        XCTAssertTrue(p.n)
        p.n = false
        XCTAssertFalse(p.n)
        p.v = true
        XCTAssertTrue(p.v)
        p.v = false
        XCTAssertFalse(p.v)
        p.r = true
        XCTAssertTrue(p.r)
        p.r = false
        XCTAssertFalse(p.r)
        p.b = true
        XCTAssertTrue(p.b)
        p.b = false
        XCTAssertFalse(p.b)
        p.d = true
        XCTAssertTrue(p.d)
        p.d = false
        XCTAssertFalse(p.d)
        p.i = true
        XCTAssertTrue(p.i)
        p.i = false
        XCTAssertFalse(p.i)
        p.z = true
        XCTAssertTrue(p.z)
        p.z = false
        XCTAssertFalse(p.z)
        p.c = true
        XCTAssertTrue(p.c)
        p.c = false
        XCTAssertFalse(p.c)
    }

    func testPDescription() {
        let pAA = Register.P(rawValue: 0b1010_1010)
        XCTAssertEqual("\(pAA)", "N_R_D_Z_")
        let p55 = Register.P(rawValue: 0b0101_0101)
        XCTAssertEqual("\(p55)", "_V_B_I_C")
    }

    func testRegister() {
        var reg = Register(a: 0, x: 0, y: 0, s: 0, p: Register.P(rawValue: 0), pc: 0)
        reg.a = 0x12
        XCTAssertEqual(0x12, reg.a)
        reg.a = 0xAB
        XCTAssertEqual(0xAB, reg.a)
        reg.x = 0x12
        XCTAssertEqual(0x12, reg.x)
        reg.x = 0xAB
        XCTAssertEqual(0xAB, reg.x)
        reg.y = 0x12
        XCTAssertEqual(0x12, reg.y)
        reg.y = 0xAB
        XCTAssertEqual(0xAB, reg.y)
        reg.s = 0x12
        XCTAssertEqual(0x12, reg.s)
        reg.s = 0xAB
        XCTAssertEqual(0xAB, reg.s)
        reg.pc = 0x1234
        XCTAssertEqual(0x1234, reg.pc)
        reg.pc = 0xABCD
        XCTAssertEqual(0xABCD, reg.pc)
    }
}
