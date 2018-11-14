//
//  Mapper.swift
//  NESwft
//
//  Created by HIROTA Ichiro on 2018/10/26.
//  Copyright © 2018 HIROTA Ichiro. All rights reserved.
//

import Foundation

// INES Mapper 000
class NROM: Memory {
    let rom: Memory

    /**
     * @param addr memory address (0x4020...0xFFFF)
     * @return memory data
     */
    subscript(addr: UInt16) -> UInt8 {
        get { return rom[addr] }
        set { rom[addr] = newValue }
    }

    class ROM16K: Memory {
        let data: Data
        init(data: Data) { self.data = data }
        subscript(addr: UInt16) -> UInt8 {
            get { return data[Int(addr & 0x3FFF)] }
            set { /*ignore*/ }
        }
    }

    class ROM32K: Memory {
        let data: Data
        init(data: Data) { self.data = data }
        subscript(addr: UInt16) -> UInt8 {
            get { return data[Int(addr & 0x7FFF)] }
            set { /*ignore*/ }
        }
    }

    init(data: Data) {
        assert(data.count == 0x4000 || data.count == 0x8000)
        rom = (data.count == 0x4000) ? ROM16K(data: data) : ROM32K(data: data)
        //print("NROM: using sub mapper=\(rom)")
    }
}
