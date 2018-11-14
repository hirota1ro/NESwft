//
//  SpriteTests.swift
//  NESwftTests
//
//  Created by HIROTA Ichiro on 2018/11/10.
//  Copyright © 2018 HIROTA Ichiro. All rights reserved.
//

import XCTest
@testable import NESwft

class SpriteTests: XCTestCase {

    func testSpriteAttr() {
        let aAA = Sprite.Attr(rawValue: 0xAA)
        XCTAssertTrue(aAA.vFlip)
        XCTAssertFalse(aAA.hFlip)
        XCTAssertTrue(aAA.behind)
        XCTAssertEqual(aAA.palette, 2)

        let a55 = Sprite.Attr(rawValue: 0x55)
        XCTAssertFalse(a55.vFlip)
        XCTAssertTrue(a55.hFlip)
        XCTAssertFalse(a55.behind)
        XCTAssertEqual(a55.palette, 1)
    }

    func testSprite() {
        let data = Data(bytes: [0x12, 0x34, 0x56, 0x78])
        let s = Sprite(data: data)
        XCTAssertEqual(s.y, 0x12)
        XCTAssertEqual(s.p, 0x34)
        XCTAssertEqual(s.a.rawValue, 0x56)
        XCTAssertEqual(s.x, 0x78)
    }
}
