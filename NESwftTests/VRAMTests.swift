//
//  VRAMTests.swift
//  NESwftTests
//
//  Created by HIROTA Ichiro on 2018/11/10.
//  Copyright © 2018 HIROTA Ichiro. All rights reserved.
//

import XCTest
@testable import NESwft

class VRAMTests: XCTestCase {

    func testNametable() {
        let nt = Nametable()

        nt[0x03C0] = 0b11_10_01_00

        let a = nt.attrTable
        XCTAssertEqual(a[0][0], 0)
        XCTAssertEqual(a[0][1], 0)
        XCTAssertEqual(a[0][2], 1)
        XCTAssertEqual(a[0][3], 1)
        XCTAssertEqual(a[1][0], 0)
        XCTAssertEqual(a[1][1], 0)
        XCTAssertEqual(a[1][2], 1)
        XCTAssertEqual(a[1][3], 1)
        XCTAssertEqual(a[2][0], 2)
        XCTAssertEqual(a[2][1], 2)
        XCTAssertEqual(a[2][2], 3)
        XCTAssertEqual(a[2][3], 3)
        XCTAssertEqual(a[3][0], 2)
        XCTAssertEqual(a[3][1], 2)
        XCTAssertEqual(a[3][2], 3)
        XCTAssertEqual(a[3][3], 3)
    }

    func testVRAM() {
        XCTAssertEqual(area(0x2012), 0)
        XCTAssertEqual(area(0x2434), 1)
        XCTAssertEqual(area(0x2856), 2)
        XCTAssertEqual(area(0x2C78), 3)
    }
}
