//
//  Sprite.swift
//  NESwft
//
//  Created by HIROTA Ichiro on 2018/11/10.
//  Copyright © 2018 HIROTA Ichiro. All rights reserved.
//

import Foundation

struct Sprite {
    let data: Data
}

extension Sprite {
    var y: Int { return Int(data[0]) }
    var p: UInt8 { return data[1] }
    var a: Attr { return Attr(rawValue: data[2]) }
    var x: Int { return Int(data[3]) }

    // 7  bit  0
    // VHbx xxLL
    // |||| ||||
    // |||| ||++- palette for sprite (0...3)
    // |||+-++--- Unimplemented
    // ||+------- Priority (0: in front of background; 1: behind background)
    // |+-------- Flip sprite horizontally
    // +--------- Flip sprite vertically
    struct Attr {
        let rawValue: UInt8
    }
}

extension Sprite.Attr {
    var palette: UInt8 { return rawValue & 3 }
    var behind: Bool { return rawValue[bit: 5].bool }
    var hFlip: Bool { return rawValue[bit: 6].bool }
    var vFlip: Bool { return rawValue[bit: 7].bool }
}

extension Sprite: CustomStringConvertible {
    var description: String {
        return "<(x,y)=(\(x.hex2),\(y.hex2)),pat=\(p.hex),a=\(a)>"
    }
}

extension Sprite.Attr: CustomStringConvertible {
    var description: String {
        let v = vFlip ? "V" : "_"
        let h = hFlip ? "H" : "_"
        let b = behind ? "b" : "_"
        return "\(v)\(h)\(b),pal=\(palette)"
    }
}
