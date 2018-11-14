//
//  FdnTests.swift
//  NESwftTests
//
//  Created by HIROTA Ichiro on 2018/11/10.
//  Copyright © 2018 HIROTA Ichiro. All rights reserved.
//

import XCTest
@testable import NESwft

class FdnTests: XCTestCase {

    func testUInt8() {
        XCTAssertTrue(UInt8(0x7F).posi)
        XCTAssertFalse(UInt8(0x80).posi)

        XCTAssertFalse(UInt8(0x7F).nega)
        XCTAssertTrue(UInt8(0x80).nega)

        XCTAssertTrue(UInt8(0x00).zero)
        XCTAssertFalse(UInt8(0x01).zero)

        var dd: UInt8 = 0
        XCTAssertEqual(dd, 0x00)
        dd[bit: 0] = 1
        XCTAssertEqual(dd, 0x01)
        dd[bit: 1] = 1
        XCTAssertEqual(dd, 0x03)

        dd = 0xAA
        XCTAssertEqual(dd[bit: 0], 0)
        XCTAssertEqual(dd[bit: 1], 1)
        XCTAssertEqual(dd[bit: 6], 0)
        XCTAssertEqual(dd[bit: 7], 1)

        XCTAssertFalse(UInt8(0x00).bool)
        XCTAssertTrue(UInt8(0x01).bool)
    }

    func testUInt16() {
        XCTAssertEqual(UInt16(lo: 0x12, hi: 0x34), 0x3412)
        XCTAssertEqual(UInt16(0x5678).lo, 0x78)
        XCTAssertEqual(UInt16(0x5678).hi, 0x56)

        var aaaa: UInt16 = 0
        XCTAssertEqual(aaaa, 0x0000)
        aaaa.lo = 0x12
        XCTAssertEqual(aaaa, 0x0012)
        aaaa.hi = 0x34
        XCTAssertEqual(aaaa, 0x3412)

        aaaa = 0xAAAA
        XCTAssertEqual(aaaa[bit: 0], 0)
        XCTAssertEqual(aaaa[bit: 1], 1)
        XCTAssertEqual(aaaa[bit: 14], 0)
        XCTAssertEqual(aaaa[bit: 15], 1)

        XCTAssertFalse(UInt16(0x0000).bool)
        XCTAssertTrue(UInt16(0x0001).bool)
    }

    func testBool() {
        XCTAssertEqual(true.byte, 1)
        XCTAssertEqual(false.byte, 0)
        XCTAssertEqual(true.word, 1)
        XCTAssertEqual(false.word, 0)
        XCTAssertEqual(true.int, 1)
        XCTAssertEqual(false.int, 0)
    }
}
