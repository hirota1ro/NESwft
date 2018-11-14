//
//  Pattern.swift
//  NESwft
//
//  Created by HIROTA Ichiro on 2018/11/10.
//  Copyright © 2018 HIROTA Ichiro. All rights reserved.
//

import Foundation

protocol Pattern {
    var size: Size { get }
    subscript(x: Int, y: Int) -> UInt8 { get }
}

extension Pattern {
    var pixels: [[UInt8]] {
        var b: [[UInt8]] = []
        for y in 0 ..< size.height {
            var a: [UInt8] = []
            for x in 0 ..< size.width {
                a.append(self[x, y])
            }
            b.append(a)
        }
        return b
    }

    var description: String {
        return pixels.map({ a in a.map({ String($0) }).joined(separator: " ") }).joined(separator: "\n")
    }
}

// Bit Planes            Pixel Pattern
// $0xx0=$41  01000001
// $0xx1=$C2  11000010
// $0xx2=$44  01000100
// $0xx3=$48  01001000
// $0xx4=$10  00010000
// $0xx5=$20  00100000         .1.....3
// $0xx6=$40  01000000         11....3.
// $0xx7=$80  10000000  =====  .1...3..
//                             .1..3...
// $0xx8=$01  00000001  =====  ...3.22.
// $0xx9=$02  00000010         ..3....2
// $0xxA=$04  00000100         .3....2.
// $0xxB=$08  00001000         3....222
// $0xxC=$16  00010110
// $0xxD=$21  00100001
// $0xxE=$42  01000010
// $0xxF=$87  10000111

// 8 × 8 Pixel Pattern
struct Pat8: Pattern {
    let data: Data

    var size: Size { return Size(width: 8, height: 8) }

    /**
     * @param x (0...7)
     * @param y (0...7)
     * @return pixel value (2bit) (0...3)
     */
    subscript(x: Int, y: Int) -> UInt8 {
        assert(0 <= x && x < 8)
        assert(0 <= y && y < 8)
        let dL = data[y]
        let dH = data[y | 0b1000]
        let b = x ^ 0b111
        let bL = (dL >> b) & 1
        let bH = (dH >> b) & 1
        let v = (bH << 1) + bL
        return v
    }
}
extension Pat8: CustomStringConvertible {}

struct VFlip: Pattern {
    let pat: Pattern

    var size: Size { return pat.size }

    subscript(x: Int, y: Int) -> UInt8 {
        assert(0 <= y && y < size.height)
        return pat[x, size.height - 1 - y]
    }
}
extension VFlip: CustomStringConvertible {}

struct HFlip: Pattern {
    let pat: Pattern

    var size: Size { return pat.size }

    subscript(x: Int, y: Int) -> UInt8 {
        assert(0 <= x && x < size.width)
        return pat[size.width - 1 - x, y]
    }
}
extension HFlip: CustomStringConvertible {}

struct Pat16: Pattern {
    let top: Pattern
    let bottom: Pattern

    init(top: Pattern,  bottom: Pattern) {
        assert(top.size == Size(width: 8, height: 8))
        assert(bottom.size == Size(width: 8, height: 8))
        self.top = top
        self.bottom = bottom
    }

    var size: Size { return Size(width: 8, height: 16) }

    subscript(x: Int, y: Int) -> UInt8 {
        assert(0 <= x && x < 8)
        assert(0 <= y && y < 16)
        if y < 8 {
            return top[x, y]
        } else {
            return bottom[x, y - 8]
        }
    }
}
extension Pat16: CustomStringConvertible {}
