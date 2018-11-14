//
//  BitmapTests.swift
//  NESwftTests
//
//  Created by HIROTA Ichiro on 2018/10/25.
//  Copyright © 2018 HIROTA Ichiro. All rights reserved.
//

import XCTest
@testable import NESwft

class BitmapTests: XCTestCase {

    func testBitmap() {
        var bitmap = Bitmap(width: 256, height: 240)

        bitmap[100, 100] = 0x123456
        XCTAssertEqual(bitmap[100, 100], 0x123456)
        bitmap[40, 50] = 0xAABBCC
        XCTAssertEqual(bitmap[40, 50], 0xAABBCC)
        bitmap[120, 130] = 0x224488
        XCTAssertEqual(bitmap[120, 130], 0x224488)

        bitmap[0, 0] = 0xABCDEF
        XCTAssertEqual(bitmap.data[0], 0xAB)
        XCTAssertEqual(bitmap.data[1], 0xCD)
        XCTAssertEqual(bitmap.data[2], 0xEF)
    }
}
