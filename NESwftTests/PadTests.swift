//
//  PadTests.swift
//  NESwftTests
//
//  Created by HIROTA Ichiro on 2018/10/29.
//  Copyright © 2018 HIROTA Ichiro. All rights reserved.
//

import XCTest
@testable import NESwft

class PadTests: XCTestCase {

    func testPad() {
        let pad = Pad()

        pad.con1.b = true
        pad.con1.right = true
        pad.con2.a = true
        pad.con2.left = true

        pad[0x4016] = 0
        pad[0x4016] = 1
        XCTAssertEqual(pad.read8byte(addr: 0x4016), 0b1000_0010) // Right, B
        XCTAssertEqual(pad.read8byte(addr: 0x4017), 0b0100_0001) // Left, A
    }
}

extension Pad {
    func read8byte(addr: UInt16) -> UInt8 {
        // read 8 bytes, to store 8 bit
        var v: UInt8 = 0
        for i in 0...7 {
            let d = self[addr]
            v |= d[bit: 0] << i
        }
        return v
    }
}
