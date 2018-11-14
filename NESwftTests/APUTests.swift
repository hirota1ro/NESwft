//
//  APUTests.swift
//  NESwftTests
//
//  Created by HIROTA Ichiro on 2018/10/25.
//  Copyright © 2018 HIROTA Ichiro. All rights reserved.
//

import XCTest
@testable import NESwft

class APUTests: XCTestCase {

    func testCtrl() {
        let ctrl55 = APU.Ctrl(rawValue: 0x55)
        XCTAssertTrue(ctrl55.DMC)
        XCTAssertFalse(ctrl55.noise)
        XCTAssertTrue(ctrl55.triangle)
        XCTAssertFalse(ctrl55.pulse2)
        XCTAssertTrue(ctrl55.pulse1)

        let ctrlAA = APU.Ctrl(rawValue: 0xAA)
        XCTAssertFalse(ctrlAA.DMC)
        XCTAssertTrue(ctrlAA.noise)
        XCTAssertFalse(ctrlAA.triangle)
        XCTAssertTrue(ctrlAA.pulse2)
        XCTAssertFalse(ctrlAA.pulse1)
    }

    func testPulse() {
        let pulseAA = APU.Pulse(data: Data(bytes: [0xAA, 0xAA, 0xAA, 0xAA]))
        XCTAssertEqual(pulseAA.duty, 0b10)
        XCTAssertTrue(pulseAA.halt)
        XCTAssertFalse(pulseAA.cVolume)
        XCTAssertEqual(pulseAA.volume, 0b1010)
        XCTAssertTrue(pulseAA.su.enabled)
        XCTAssertEqual(pulseAA.su.period, 0b010)
        XCTAssertTrue(pulseAA.su.negate)
        XCTAssertEqual(pulseAA.su.shift, 0b010)
        XCTAssertEqual(pulseAA.timer, 0b010_1010_1010)
        XCTAssertEqual(pulseAA.load, 0b1010_1)

        let pulse55 = APU.Pulse(data: Data(bytes: [0x55, 0x55, 0x55, 0x55]))
        XCTAssertEqual(pulse55.duty, 0b01)
        XCTAssertFalse(pulse55.halt)
        XCTAssertTrue(pulse55.cVolume)
        XCTAssertEqual(pulse55.volume, 0b0101)
        XCTAssertFalse(pulse55.su.enabled)
        XCTAssertEqual(pulse55.su.period, 0b101)
        XCTAssertFalse(pulse55.su.negate)
        XCTAssertEqual(pulse55.su.shift, 0b101)
        XCTAssertEqual(pulse55.timer, 0b101_0101_0101)
        XCTAssertEqual(pulse55.load, 0b0101_0)
    }

    func testTriangle() {
        let triangleAA = APU.Triangle(data: Data(bytes: [0xAA, 0xAA, 0xAA, 0xAA]))
        XCTAssertTrue(triangleAA.halt)
        XCTAssertEqual(triangleAA.road, 0b010_1010)
        XCTAssertEqual(triangleAA.timer, 0b010_1010_1010)
        XCTAssertEqual(triangleAA.load, 0b1010_1)
        let triangle55 = APU.Triangle(data: Data(bytes: [0x55, 0x55, 0x55, 0x55]))
        XCTAssertFalse(triangle55.halt)
        XCTAssertEqual(triangle55.road, 0b101_0101)
        XCTAssertEqual(triangle55.timer, 0b101_0101_0101)
        XCTAssertEqual(triangle55.load, 0b0101_0)
    }

    func testNoise() {
        let noiseAA = APU.Noise(data: Data(bytes: [0xAA, 0xAA, 0xAA, 0xAA]))
        XCTAssertTrue(noiseAA.halt)
        XCTAssertFalse(noiseAA.cVolume)
        XCTAssertEqual(noiseAA.volume, 0b1010)
        XCTAssertTrue(noiseAA.loop)
        XCTAssertEqual(noiseAA.period, 0b1010)
        XCTAssertEqual(noiseAA.load, 0b1010_1)
        let noise55 = APU.Noise(data: Data(bytes: [0x55, 0x55, 0x55, 0x55]))
        XCTAssertFalse(noise55.halt)
        XCTAssertTrue(noise55.cVolume)
        XCTAssertEqual(noise55.volume, 0b0101)
        XCTAssertFalse(noise55.loop)
        XCTAssertEqual(noise55.period, 0b0101)
        XCTAssertEqual(noise55.load, 0b0101_0)
    }

    func testDMC() {
        let dmcAA = APU.DMC(data: Data(bytes: [0xAA, 0xAA, 0xAA, 0xAA]))
        XCTAssertTrue(dmcAA.enableIRQ)
        XCTAssertFalse(dmcAA.loop)
        XCTAssertEqual(dmcAA.frequency, 0b1010)
        XCTAssertEqual(dmcAA.counter, 0b010_1010)
        XCTAssertEqual(dmcAA.address, 0xAA)
        XCTAssertEqual(dmcAA.length, 0xAA)
        let dmc55 = APU.DMC(data: Data(bytes: [0x55, 0x55, 0x55, 0x55]))
        XCTAssertFalse(dmc55.enableIRQ)
        XCTAssertTrue(dmc55.loop)
        XCTAssertEqual(dmc55.frequency, 0b0101)
        XCTAssertEqual(dmc55.counter, 0b101_0101)
        XCTAssertEqual(dmc55.address, 0x55)
        XCTAssertEqual(dmc55.length, 0x55)
    }

    func testAPU() {
    }
}
