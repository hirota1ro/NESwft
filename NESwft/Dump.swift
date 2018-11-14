//
//  Dump.swift
//  NESwft
//
//  Created by HIROTA Ichiro on 2018/10/28.
//  Copyright © 2018 HIROTA Ichiro. All rights reserved.
//

import Foundation

extension Data {
    func hexDump() -> String {
        var a: [String] = []
        let pages = Swift.min((self.count + 255) / 256, 256)
        for page in 0 ..< pages {
            let s = page * 256
            let z = Swift.min(self.count - s, 256)
            let p = self.subdata(in: s ..< (s + z))
            a.append(p.pageDump(prefix: s))
        }
        return a.joined(separator: "\n--------------------------------------------------\n")
    }

    func pageDump(prefix: Int) -> String {
        var a: [String] = []
        a.append("addr: +0 +1 +2 +3 +4 +5 +6 +7 +8 +9 +a +b +c +d +e +f")
        let size = Swift.min(self.count, 256)
        let rows = (size + 15) / 16
        for row in 0 ..< rows {
            let s = row * 16
            let z = Swift.min(self.count - s, 16)
            let line = self.subdata(in: s ..< (s + z))
            a.append(line.lineDump(prefix: prefix + s))
        }
        return a.joined(separator: "\n")
    }

    func lineDump(prefix: Int) -> String {
        var a: [String] = []
        let n = Swift.min(self.count, 16)
        for i in 0 ..< n {
            let b = self[i]
            a.append(b.hex)
        }
        let t = a.joined(separator: " ")
        return ("\(prefix.hex4): \(t)")
    }
}
