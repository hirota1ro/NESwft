//
//  PatternTests.swift
//  NESwftTests
//
//  Created by HIROTA Ichiro on 2018/11/10.
//  Copyright © 2018 HIROTA Ichiro. All rights reserved.
//

import XCTest
@testable import NESwft

class PatternTests: XCTestCase {

    func testPat8() {
        let data = Data(bytes: [0x41, 0xC2, 0x44, 0x48, 0x10, 0x20, 0x40, 0x80,
                                0x01, 0x02, 0x04, 0x08, 0x16, 0x21, 0x42, 0x87])
        let pat8 = Pat8(data: data)
        XCTAssertEqual(pat8[0, 0], 0)
        XCTAssertEqual(pat8[1, 0], 1)
        XCTAssertEqual(pat8[7, 0], 3)
        XCTAssertEqual(pat8[7, 7], 2)
    }

    func testPat16() {
        let bT: [UInt8] = [
          1,2,2,2,2,2,2,2,
          1,0,0,0,0,0,0,2,
          1,0,0,0,0,0,0,2,
          1,0,0,0,0,0,0,2,
          1,0,0,0,0,0,0,2,
          1,0,0,0,0,0,0,2,
          1,0,0,0,0,0,0,2,
          1,0,0,0,0,0,0,2,
        ]
        let bB: [UInt8] = [
          1,0,0,0,0,0,0,3,
          1,0,0,0,0,0,0,3,
          1,0,0,0,0,0,0,3,
          1,0,0,0,0,0,0,3,
          1,0,0,0,0,0,0,3,
          1,0,0,0,0,0,0,3,
          1,0,0,0,0,0,0,3,
          3,3,3,3,3,3,3,3,
        ]
        let pT = StubPattern(size: Size(width: 8, height: 8), bytes: bT)
        let pB = StubPattern(size: Size(width: 8, height: 8), bytes: bB)
        let p = Pat16(top: pT, bottom: pB)
        XCTAssertEqual(p[0, 0], 1)
        XCTAssertEqual(p[7, 0], 2)
        XCTAssertEqual(p[0, 8], 1)
        XCTAssertEqual(p[7, 8], 3)
        XCTAssertEqual(p[0, 15], 3)
        XCTAssertEqual(p[0, 15], 3)
    }

    func testVFlip() {
        let b: [UInt8] = [
          1,2,2,2,2,2,2,2,
          1,0,0,0,0,0,0,3,
          1,0,0,0,0,0,0,3,
          1,0,0,0,0,0,0,3,
          1,0,0,0,0,0,0,3,
          1,0,0,0,0,0,0,3,
          1,0,0,0,0,0,0,3,
          0,0,0,0,0,0,0,3,
        ]
        let p = StubPattern(size: Size(width: 8, height: 8), bytes: b)
        let v = VFlip(pat: p)
        XCTAssertEqual(v[0, 0], 0)
        XCTAssertEqual(v[0, 7], 1)
        XCTAssertEqual(v[7, 0], 3)
        XCTAssertEqual(v[7, 7], 2)
    }

    func testHFlip() {
        let b: [UInt8] = [
          1,2,2,2,2,2,2,2,
          1,0,0,0,0,0,0,3,
          1,0,0,0,0,0,0,3,
          1,0,0,0,0,0,0,3,
          1,0,0,0,0,0,0,3,
          1,0,0,0,0,0,0,3,
          1,0,0,0,0,0,0,3,
          0,0,0,0,0,0,0,3,
        ]
        let p = StubPattern(size: Size(width: 8, height: 8), bytes: b)
        let h = HFlip(pat: p)
        XCTAssertEqual(h[0, 0], 2)
        XCTAssertEqual(h[0, 7], 3)
        XCTAssertEqual(h[7, 0], 1)
        XCTAssertEqual(h[7, 7], 0)
    }
}

struct StubPattern: Pattern {
    var size: Size
    var bytes: [UInt8]

    subscript(x: Int, y: Int) -> UInt8 { return bytes[y * 8 + x] }
}
