//
//  PointTests.swift
//  NESwftTests
//
//  Created by HIROTA Ichiro on 2018/11/10.
//  Copyright © 2018 HIROTA Ichiro. All rights reserved.
//

import XCTest
@testable import NESwft

class PointTests: XCTestCase {

    func testSize() {
        let sz = Size(width: 3, height: 2)
        var c = 0
        var maxX = -1
        var maxY = -1
        sz.forEach { p in
            c += 1
            maxX = Swift.max(maxX, p.x)
            maxY = Swift.max(maxY, p.y)
        }
        XCTAssertEqual(c, 3*2)
        XCTAssertEqual(maxX, 3-1)
        XCTAssertEqual(maxY, 2-1)
    }

    func testRect() {
        let r = Rect(x: 0, y: 16, width: 256, height: 8)
        //
        let r2 = Rect(x: 120, y: 10, width: 8, height: 8)
        XCTAssertTrue(r.intersects(rect: r2))
        XCTAssertTrue(r2.intersects(rect: r))
        //
        let r3 = Rect(x: 130, y: 20, width: 8, height: 8)
        XCTAssertTrue(r.intersects(rect: r3))
        XCTAssertTrue(r3.intersects(rect: r))
        //
        let r4 = Rect(x: 140, y: 0, width: 8, height: 8)
        XCTAssertFalse(r.intersects(rect: r4))
        XCTAssertFalse(r4.intersects(rect: r))
        //
        let r5 = Rect(x: 150, y: 40, width: 8, height: 8)
        XCTAssertFalse(r.intersects(rect: r5))
        XCTAssertFalse(r5.intersects(rect: r))
        //
    }
}
