//
//  PaletteTests.swift
//  NESwftTests
//
//  Created by HIROTA Ichiro on 2018/11/10.
//  Copyright © 2018 HIROTA Ichiro. All rights reserved.
//

import XCTest
@testable import NESwft

class PaletteTests: XCTestCase {

    func testPaletteMemory() {
        let palmem = PalMem()
        for addr: UInt16 in 0x3F00 ... 0x3F1F {
            palmem[0x3F1F] = addr.lo
        }
        // print("-- Palette Memory (RAW) --\n\(palmem.data.hexDump())")
        // Addresses 0x3F10/0x3F14/0x3F18/0x3F1C are mirrors of 0x3F00/0x3F04/0x3F08/0x3F0C.
        XCTAssertEqual(palmem[mirror: 0x3F10], palmem[mirror: 0x3F00])
        XCTAssertEqual(palmem[mirror: 0x3F14], palmem[mirror: 0x3F04])
        XCTAssertEqual(palmem[mirror: 0x3F18], palmem[mirror: 0x3F08])
        XCTAssertEqual(palmem[mirror: 0x3F1C], palmem[mirror: 0x3F0C])

        XCTAssertEqual(palmem[cooked: 0x3F04], palmem[cooked: 0x3F00])
        XCTAssertEqual(palmem[cooked: 0x3F08], palmem[cooked: 0x3F00])
        XCTAssertEqual(palmem[cooked: 0x3F0C], palmem[cooked: 0x3F00])

        XCTAssertEqual(palmem[cooked: 0x3F10], palmem[cooked: 0x3F00])
        XCTAssertEqual(palmem[cooked: 0x3F14], palmem[cooked: 0x3F00])
        XCTAssertEqual(palmem[cooked: 0x3F18], palmem[cooked: 0x3F00])
        XCTAssertEqual(palmem[cooked: 0x3F1C], palmem[cooked: 0x3F00])
    }

}
