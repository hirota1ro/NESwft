//
//  MapperTests.swift
//  NESwftTests
//
//  Created by HIROTA Ichiro on 2018/10/26.
//  Copyright © 2018 HIROTA Ichiro. All rights reserved.
//

import XCTest
@testable import NESwft

class MapperTests: XCTestCase {

    func testMapper() {
        var data = Data(count: 0x4000) // 16K
        data[0x0000] = 0x12
        data[0x0001] = 0x34
        data[0x3FFE] = 0xCD
        data[0x3FFF] = 0xEF

        let mpr = NROM(data: data)

        XCTAssertEqual(mpr[0x8000], 0x12)
        XCTAssertEqual(mpr[0x8001], 0x34)
        XCTAssertEqual(mpr[0xBFFE], 0xCD)
        XCTAssertEqual(mpr[0xBFFF], 0xEF)
        XCTAssertEqual(mpr[0xC000], 0x12)
        XCTAssertEqual(mpr[0xC001], 0x34)
        XCTAssertEqual(mpr[0xFFFE], 0xCD)
        XCTAssertEqual(mpr[0xFFFF], 0xEF)
    }
}
