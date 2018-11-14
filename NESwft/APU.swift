//
//  APU.swift
//  NESwft
//
//  Created by HIROTA Ichiro on 2018/10/25.
//  Copyright © 2018 HIROTA Ichiro. All rights reserved.
//

import Foundation

// See APU Registers for a complete APU register diagram.
// Registers	Channel	Units
// $4000-$4003	Pulse 1		Timer, length counter, envelope, sweep
// $4004-$4007	Pulse 2		Timer, length counter, envelope, sweep
// $4008-$400B	Triangle	Timer, length counter, linear counter
// $400C-$400F	Noise		Timer, length counter, envelope, linear feedback shift register
// $4010-$4013	DMC		Timer, memory reader, sample buffer, output unit
// $4015	All		Channel enable and length counter status
// $4017	All		Frame counter

class APU {
    var data = Data(count: 0x20)
    var ctrl: UInt8 = 0 {
        didSet {
            control()
        }
    }
    var audio: APUAudio? = nil
}

protocol APUAudio {
    func start(pulse1: APU.Pulse)
    func stopPulse1()
    func start(pulse2: APU.Pulse)
    func stopPulse2()
    func start(triangle: APU.Triangle)
    func stopTriangle()
    func start(noise: APU.Noise)
    func stopNoise()
    func start(dmc: APU.DMC)
    func stopDMC()
}

extension APU: Memory {
    subscript(addr: UInt16) -> UInt8 {
        get {
            if addr == 0x4015 {
                return stat
            } else {
                return data[Int(addr & 0x1F)]
            }
        }
        set {
            if addr == 0x4015 {
                ctrl = newValue
            } else {
                data[Int(addr & 0x1F)] = newValue
            }
        }
    }
}

extension APU {
    struct Ctrl { let rawValue: UInt8 }
    struct Pulse { let data: Data }
    struct Triangle { let data: Data }
    struct Noise { let data: Data }
    struct DMC { let data: Data }
}

// Control
// 7  bit  0
// ---D NT21
//    | |||+- Pulse 1 (1: Enable, 0: Disable)
//    | ||+-- Pulse 2 (1: Enable, 0: Disable)
//    | |+--- Triangle (1: Enable, 0: Disable)
//    | +---- Noise (1: Enable, 0: Disable)
//    +------ DMC (1: Enable, 0: Disable)
extension APU.Ctrl {
    var DMC: Bool { return rawValue[bit: 4].bool }
    var noise: Bool { return rawValue[bit: 3].bool }
    var triangle: Bool { return rawValue[bit: 2].bool }
    var pulse2: Bool { return rawValue[bit: 1].bool }
    var pulse1: Bool { return rawValue[bit: 0].bool }
}

// Pulse
// $4000, $4004	DDLC VVVV	Duty (D), envelope loop / length counter halt (L), constant volume (C), volume/envelope (V)
// $4001, $4005	EPPP NSSS	Sweep unit: enabled (E), period (P), negate (N), shift (S)
// $4002, $4006	TTTT TTTT	Timer low (T)
// $4003, $4007	LLLL LTTT	Length counter load (L), timer high (T)
extension APU.Pulse {
    var duty: Int { return Int(data[0] >> 6) & 3 }
    var halt: Bool { return data[0][bit: 5].bool }
    var cVolume: Bool { return data[0][bit: 4].bool }
    var volume: Int { return Int(data[0]) & 0xF }

    struct SweepUnit { let rawValue: UInt8 }
    var su: SweepUnit { return SweepUnit(rawValue: data[1]) }

    var timer: Int {
        let lo = Int(data[2])
        let hi = Int(data[3]) & 7
        return (hi << 8) | lo
    }

    var load: Int { return Int(data[3] >> 3) & 0x1F }
}

extension APU.Pulse.SweepUnit {
    var enabled: Bool { return rawValue[bit: 7].bool }
    var period: Int { return Int(rawValue >> 4) & 7 }
    var negate: Bool { return rawValue[bit: 3].bool }
    var shift: Int { return Int(rawValue) & 7 }
}

// Triangle
// $4008 CRRR RRRR	Length counter halt / linear counter control (C), linear counter load (R)
// $4009 ---- ----	Unused
// $400A TTTT TTTT	Timer low (T)
// $400B LLLL LTTT	Length counter load (L), timer high (T)
extension APU.Triangle {
    var halt: Bool { return data[0][bit: 7].bool }
    var road: Int { return Int(data[0]) & 0x7F }

    var timer: Int {
        let lo = Int(data[2])
        let hi = Int(data[3]) & 7
        return (hi << 8) | lo
    }

    var load: Int { return Int(data[3] >> 3) & 0x1F }
}

// Noise
// $400C --LC VVVV	Envelope loop / length counter halt (L), constant volume (C), volume/envelope (V)
// $400D ---- ----	Unused
// $400E L--- PPPP	Loop noise (L), noise period (P)
// $400F LLLL L---	Length counter load (L)
extension APU.Noise {
    var halt: Bool { return data[0][bit: 5].bool }
    var cVolume: Bool { return data[0][bit: 4].bool }
    var volume: Int { return Int(data[0]) & 0xF }

    var loop: Bool { return data[2][bit: 7].bool }
    var period: Int { return Int(data[2]) & 0x0F }

    var load: Int { return Int(data[3] >> 3) & 0x1F }
}

// DMC
// $4010 IL-- RRRR	IRQ enable (I), loop (L), frequency (R)
// $4011 -DDD DDDD	Load counter (D)
// $4012 AAAA AAAA	Sample address (A)
// $4013 LLLL LLLL	Sample length (L)
extension APU.DMC {

    var enableIRQ: Bool { return data[0][bit: 7].bool }
    var loop: Bool { return data[0][bit: 6].bool }
    var frequency: Int { return Int(data[0]) & 0xF }

    var counter: Int { return Int(data[1]) & 0x7F }

    var address: Int { return Int(data[2]) }
    var length: Int { return Int(data[3]) }
}

extension APU {
    // $4015 read
    var stat: UInt8 {
        return ctrl | 0x00
    }

    // $4015 write
    func control() {
        let enable = Ctrl(rawValue: ctrl)
        if enable.pulse1 {
            audio?.start(pulse1: Pulse(data: data.subdata(in: 0 ..< 4)))
        } else {
            audio?.stopPulse1()
        }
        if enable.pulse2 {
            audio?.start(pulse2: Pulse(data: data.subdata(in: 4 ..< 8)))
        } else {
            audio?.stopPulse1()
        }
        if enable.triangle {
            audio?.start(triangle: Triangle(data: data.subdata(in: 8 ..< 12)))
        } else {
            audio?.stopTriangle()
        }
        if enable.noise {
            audio?.start(noise: Noise(data: data.subdata(in: 12 ..< 16)))
        } else {
            audio?.stopNoise()
        }
        if enable.DMC {
            audio?.start(dmc: DMC(data: data.subdata(in: 16 ..< 20)))
        } else {
            audio?.stopDMC()
        }
    }
}

extension APU {
    func reset() {
        // After reset
        // APU mode in $4017 was unchanged
        // APU was silenced ($4015 = 0)
        self[0x4015] = 0
    }
}
