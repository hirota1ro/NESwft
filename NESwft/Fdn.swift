//
//  Fdn.swift
//  NESwft
//
//  Created by HIROTA Ichiro on 2018/11/10.
//  Copyright © 2018 HIROTA Ichiro. All rights reserved.
//

import Foundation

extension Int {
    var hex8: String { return String(format: "%08x", self) }
    var hex4: String { return String(format: "%04x", self) }
    var hex2: String { return String(format: "%02x", self) }
}

extension UInt32 {
    var hex: String { return String(format: "%08x", self) }
}

extension UInt16 {
    @inlinable
    init(lo: UInt8, hi: UInt8) { self.init(UInt16(hi) * 256 + UInt16(lo)) }
    @inlinable
    var lo: UInt8 {
        get { return UInt8(self & 0x00FF) }
        set { self = (self & 0xFF00) | UInt16(newValue) }
    }
    @inlinable
    var hi: UInt8 {
        get { return UInt8((self >> 8) & 0x00FF) }
        set { self = (self & 0x00FF) | (UInt16(newValue) << 8) }
    }
    @inlinable
    subscript(bit b: Int) -> UInt16 {
        get { return (self >> b) & 1 }
        set { self = (self & ~(1 << b)) | (newValue << b) }
    }
    @inlinable
    var bool: Bool {
        get { return self != 0 }
        set { self = newValue ? 1 : 0 }
    }
    var hex: String { return String(format: "%04x", self) }
}

extension UInt8 {
    @inlinable
    var posi: Bool { return (self & 0b1000_0000) == 0 }
    @inlinable
    var nega: Bool { return (self & 0b1000_0000) != 0 }
    @inlinable
    var zero: Bool { return self == 0 }
    @inlinable
    subscript(bit b: Int) -> UInt8 {
        get { return (self >> b) & 1 }
        set { self = (self & ~(1 << b)) | (newValue << b) }
    }
    @inlinable
    var bool: Bool {
        get { return self != 0 }
        set { self = newValue ? 1 : 0 }
    }
    var hex: String { return String(format: "%02x", self) }
    var bin: String {
        return (0...7).reversed().map({ String(self[bit: $0]) }).joined(separator: "")
    }
}

extension Bool {
    @inlinable
    var byte: UInt8 { return self ? 1 : 0 }
    @inlinable
    var word: UInt16 { return self ? 1 : 0 }
    @inlinable
    var int: Int { return self ? 1 : 0 }
}
