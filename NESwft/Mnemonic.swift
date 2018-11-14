//
//  Mnemonic.swift
//  NESwft
//
//  Created by HIROTA Ichiro on 2018/10/27.
//  Copyright © 2018 HIROTA Ichiro. All rights reserved.
//

import Foundation

enum Mnemonic {
    case ADC, AHX, ALR, ANC, AND, ARR, ASL, AXS, BCC, BCS, BEQ, BIT, BMI, BNE,
         BPL, BRK, BVC, BVS, CLC, CLD, CLI, CLV, CMP, CPX, CPY, DCP, DEC, DEX,
         DEY, EOR, INC, INX, INY, ISC, JMP, JSR, LAS, LAX, LDA, LDX, LDY, LSR,
         NOP, ORA, PHA, PHP, PLA, PLP, RLA, ROL, ROR, RRA, RTI, RTS, SAX, SBC,
         SEC, SED, SEI, SHX, SHY, SLO, SRE, STA, STP, STX, STY, TAS, TAX, TAY,
         TSX, TXA, TXS, TYA, XAA
}

// Addressing Mode
enum Addressing {
    case Absolute
    case Absolute_X
    case Absolute_Y
    case Accumulator
    case Immediate
    case Implied
    case Indirect
    case Indirect_X
    case Indirect_Y
    case Relative
    case ZeroPage
    case ZeroPage_X
    case ZeroPage_Y
}

// Operand
enum Operand {
    case void
    case byte(UInt8)
    case word(UInt16)

    var byte: UInt8 {
        switch self {
        case .void:
            fatalError("no data")
        case let .byte(dd):
            return dd
        case let .word(aaaa):
            fatalError("word \(aaaa.hex) missing high byte")
        }
    }

    var word: UInt16 {
        switch self {
        case .void:
            fatalError("no data")
        case let .byte(dd):
            fatalError("byte \(dd.hex) expand high byte")
        case let .word(aaaa):
            return aaaa
        }
    }

    var size: UInt16 {
        switch self {
        case .void: return 0
        case .byte: return 1
        case .word: return 2
        }
    }
}

extension Operand: CustomStringConvertible {
    var description: String {
        switch self {
        case .void:
            return "      " // spc × 6
        case let .byte(dd):
            return "\(dd.hex)    "
        case let .word(aaaa):
            return "\(aaaa.lo.hex) \(aaaa.hi.hex) "
        }
    }
}

// Declaration
struct Decl {
    let mnemonic: Mnemonic
    let mode: Addressing
    let clocks: Int
    let clkopt: Bool            // * true : add 1 cycle if page boundary is crossed.
}

extension Decl {
    init(_ mnemonic: Mnemonic, _ mode: Addressing, _ clocks: Int = 99, _ clkopt: Bool = false) {
        self.init(mnemonic: mnemonic, mode: mode, clocks: clocks, clkopt: clkopt)
    }
}

// Decoder
struct Decoder {

    static let table: [Decl] = [
      Decl(.BRK, .Implied, 7),
      Decl(.ORA, .Indirect_X, 6),
      Decl(.STP, .Implied),
      Decl(.SLO, .Indirect_X, 8),
      Decl(.NOP, .ZeroPage, 3),
      Decl(.ORA, .ZeroPage, 3),
      Decl(.ASL, .ZeroPage, 5),
      Decl(.SLO, .ZeroPage, 5),
      Decl(.PHP, .Implied, 3),
      Decl(.ORA, .Immediate, 2),
      Decl(.ASL, .Accumulator, 2),
      Decl(.ANC, .Immediate, 2),
      Decl(.NOP, .Absolute, 4),
      Decl(.ORA, .Absolute, 4),
      Decl(.ASL, .Absolute, 6),
      Decl(.SLO, .Absolute, 6),

      Decl(.BPL, .Relative, 2, true),
      Decl(.ORA, .Indirect_Y, 5, true),
      Decl(.STP, .Implied),
      Decl(.SLO, .Indirect_Y, 8),
      Decl(.NOP, .ZeroPage_X, 4),
      Decl(.ORA, .ZeroPage_X, 4),
      Decl(.ASL, .ZeroPage_X, 6),
      Decl(.SLO, .ZeroPage_X, 6),
      Decl(.CLC, .Implied, 2),
      Decl(.ORA, .Absolute_Y, 4, true),
      Decl(.NOP, .Implied, 2),
      Decl(.SLO, .Absolute_Y, 7),
      Decl(.NOP, .Absolute_X, 4, true),
      Decl(.ORA, .Absolute_X, 4, true),
      Decl(.ASL, .Absolute_X, 7),
      Decl(.SLO, .Absolute_X, 7),

      Decl(.JSR, .Absolute, 6),
      Decl(.AND, .Indirect_X, 6),
      Decl(.STP, .Implied),
      Decl(.RLA, .Indirect_X, 8),
      Decl(.BIT, .ZeroPage, 3),
      Decl(.AND, .ZeroPage, 3),
      Decl(.ROL, .ZeroPage, 5),
      Decl(.RLA, .ZeroPage, 5),
      Decl(.PLP, .Implied, 4),
      Decl(.AND, .Immediate, 2),
      Decl(.ROL, .Accumulator, 2),
      Decl(.ANC, .Immediate, 2),
      Decl(.BIT, .Absolute, 4),
      Decl(.AND, .Absolute, 4),
      Decl(.ROL, .Absolute, 6),
      Decl(.RLA, .Absolute, 6),

      Decl(.BMI, .Relative, 2, true),
      Decl(.AND, .Indirect_Y, 5, true),
      Decl(.STP, .Implied),
      Decl(.RLA, .Indirect_Y, 8),
      Decl(.NOP, .ZeroPage_X, 4),
      Decl(.AND, .ZeroPage_X, 4),
      Decl(.ROL, .ZeroPage_X, 6),
      Decl(.RLA, .ZeroPage_X, 6),
      Decl(.SEC, .Implied, 2),
      Decl(.AND, .Absolute_Y, 4, true),
      Decl(.NOP, .Implied, 2),
      Decl(.RLA, .Absolute_Y, 7),
      Decl(.NOP, .Absolute_X, 4, true),
      Decl(.AND, .Absolute_X, 4, true),
      Decl(.ROL, .Absolute_X, 7),
      Decl(.RLA, .Absolute_X, 7),

      Decl(.RTI, .Implied, 6),
      Decl(.EOR, .Indirect_X, 6),
      Decl(.STP, .Implied),
      Decl(.SRE, .Indirect_X, 8),
      Decl(.NOP, .ZeroPage, 3),
      Decl(.EOR, .ZeroPage, 3),
      Decl(.LSR, .ZeroPage, 5),
      Decl(.SRE, .ZeroPage, 5),
      Decl(.PHA, .Implied, 3),
      Decl(.EOR, .Immediate, 2),
      Decl(.LSR, .Accumulator, 2),
      Decl(.ALR, .Immediate, 2),
      Decl(.JMP, .Absolute, 3),
      Decl(.EOR, .Absolute, 4),
      Decl(.LSR, .Absolute, 6),
      Decl(.SRE, .Absolute, 6),

      Decl(.BVC, .Relative, 2, true),
      Decl(.EOR, .Indirect_Y, 5, true),
      Decl(.STP, .Implied),
      Decl(.SRE, .Indirect_Y, 8),
      Decl(.NOP, .ZeroPage_X, 4),
      Decl(.EOR, .ZeroPage_X, 4),
      Decl(.LSR, .ZeroPage_X, 6),
      Decl(.SRE, .ZeroPage_X, 6),
      Decl(.CLI, .Implied, 2),
      Decl(.EOR, .Absolute_Y, 4, true),
      Decl(.NOP, .Implied, 2),
      Decl(.SRE, .Absolute_Y, 7),
      Decl(.NOP, .Absolute_X, 4, true),
      Decl(.EOR, .Absolute_X, 4, true),
      Decl(.LSR, .Absolute_X, 7),
      Decl(.SRE, .Absolute_X, 7),

      Decl(.RTS, .Implied, 6),
      Decl(.ADC, .Indirect_X, 6),
      Decl(.STP, .Implied),
      Decl(.RRA, .Indirect_X, 8),
      Decl(.NOP, .ZeroPage, 3),
      Decl(.ADC, .ZeroPage, 3),
      Decl(.ROR, .ZeroPage, 5),
      Decl(.RRA, .ZeroPage, 5),
      Decl(.PLA, .Implied, 4),
      Decl(.ADC, .Immediate, 2),
      Decl(.ROR, .Accumulator, 2),
      Decl(.ARR, .Immediate, 2),
      Decl(.JMP, .Indirect, 5),
      Decl(.ADC, .Absolute, 4),
      Decl(.ROR, .Absolute, 6),
      Decl(.RRA, .Absolute, 6),

      Decl(.BVS, .Relative, 2, true),
      Decl(.ADC, .Indirect_Y, 5, true),
      Decl(.STP, .Implied),
      Decl(.RRA, .Indirect_Y, 8),
      Decl(.NOP, .ZeroPage_X, 4),
      Decl(.ADC, .ZeroPage_X, 4),
      Decl(.ROR, .ZeroPage_X, 6),
      Decl(.RRA, .ZeroPage_X, 6),
      Decl(.SEI, .Implied, 2),
      Decl(.ADC, .Absolute_Y, 4, true),
      Decl(.NOP, .Implied, 2),
      Decl(.RRA, .Absolute_Y, 7),
      Decl(.NOP, .Absolute_X, 4, true),
      Decl(.ADC, .Absolute_X, 4, true),
      Decl(.ROR, .Absolute_X, 7),
      Decl(.RRA, .Absolute_X, 7),

      Decl(.NOP, .Immediate, 2),
      Decl(.STA, .Indirect_X, 6),
      Decl(.NOP, .Immediate, 2),
      Decl(.SAX, .Indirect_X, 6),
      Decl(.STY, .ZeroPage, 3),
      Decl(.STA, .ZeroPage, 3),
      Decl(.STX, .ZeroPage, 3),
      Decl(.SAX, .ZeroPage, 3),
      Decl(.DEY, .Implied, 2),
      Decl(.NOP, .Immediate, 2),
      Decl(.TXA, .Implied, 2),
      Decl(.XAA, .Immediate, 2),
      Decl(.STY, .Absolute, 4),
      Decl(.STA, .Absolute, 4),
      Decl(.STX, .Absolute, 4),
      Decl(.SAX, .Absolute, 4),

      Decl(.BCC, .Relative, 2, true),
      Decl(.STA, .Indirect_Y, 6),
      Decl(.STP, .Implied),
      Decl(.AHX, .Indirect_Y, 6),
      Decl(.STY, .ZeroPage_X, 4),
      Decl(.STA, .ZeroPage_X, 4),
      Decl(.STX, .ZeroPage_Y, 4),
      Decl(.SAX, .ZeroPage_Y, 4),
      Decl(.TYA, .Implied, 2),
      Decl(.STA, .Absolute_Y, 5),
      Decl(.TXS, .Implied, 2),
      Decl(.TAS, .Absolute_Y, 5),
      Decl(.SHY, .Absolute_X, 5),
      Decl(.STA, .Absolute_X, 5),
      Decl(.SHX, .Absolute_Y, 5),
      Decl(.AHX, .Absolute_Y, 5),

      Decl(.LDY, .Immediate, 2),
      Decl(.LDA, .Indirect_X, 6),
      Decl(.LDX, .Immediate, 2),
      Decl(.LAX, .Indirect_X, 6),
      Decl(.LDY, .ZeroPage, 3),
      Decl(.LDA, .ZeroPage, 3),
      Decl(.LDX, .ZeroPage, 3),
      Decl(.LAX, .ZeroPage, 3),
      Decl(.TAY, .Implied, 2),
      Decl(.LDA, .Immediate, 2),
      Decl(.TAX, .Implied, 2),
      Decl(.LAX, .Immediate, 2),
      Decl(.LDY, .Absolute, 4),
      Decl(.LDA, .Absolute, 4),
      Decl(.LDX, .Absolute, 4),
      Decl(.LAX, .Absolute, 4),

      Decl(.BCS, .Relative, 2, true),
      Decl(.LDA, .Indirect_Y, 5, true),
      Decl(.STP, .Implied),
      Decl(.LAX, .Indirect_Y, 5, true),
      Decl(.LDY, .ZeroPage_X, 4),
      Decl(.LDA, .ZeroPage_X, 4),
      Decl(.LDX, .ZeroPage_Y, 4),
      Decl(.LAX, .ZeroPage_Y, 4),
      Decl(.CLV, .Implied, 2),
      Decl(.LDA, .Absolute_Y, 4, true),
      Decl(.TSX, .Implied, 2),
      Decl(.LAS, .Absolute_Y, 4, true),
      Decl(.LDY, .Absolute_X, 4, true),
      Decl(.LDA, .Absolute_X, 4, true),
      Decl(.LDX, .Absolute_Y, 4, true),
      Decl(.LAX, .Absolute_Y, 4, true),

      Decl(.CPY, .Immediate, 2),
      Decl(.CMP, .Indirect_X, 6),
      Decl(.NOP, .Immediate, 2),
      Decl(.DCP, .Indirect_X, 8),
      Decl(.CPY, .ZeroPage, 3),
      Decl(.CMP, .ZeroPage, 3),
      Decl(.DEC, .ZeroPage, 5),
      Decl(.DCP, .ZeroPage, 5),
      Decl(.INY, .Implied, 2),
      Decl(.CMP, .Immediate, 2),
      Decl(.DEX, .Implied, 2),
      Decl(.AXS, .Immediate, 2),
      Decl(.CPY, .Absolute, 4),
      Decl(.CMP, .Absolute, 4),
      Decl(.DEC, .Absolute, 6),
      Decl(.DCP, .Absolute, 6),

      Decl(.BNE, .Relative, 2, true),
      Decl(.CMP, .Indirect_Y, 5, true),
      Decl(.STP, .Implied),
      Decl(.DCP, .Indirect_Y, 8),
      Decl(.NOP, .ZeroPage_X, 4),
      Decl(.CMP, .ZeroPage_X, 4),
      Decl(.DEC, .ZeroPage_X, 6),
      Decl(.DCP, .ZeroPage_X, 6),
      Decl(.CLD, .Implied, 2),
      Decl(.CMP, .Absolute_Y, 4, true),
      Decl(.NOP, .Implied, 2),
      Decl(.DCP, .Absolute_Y, 7),
      Decl(.NOP, .Absolute_X, 4, true),
      Decl(.CMP, .Absolute_X, 4, true),
      Decl(.DEC, .Absolute_X, 7),
      Decl(.DCP, .Absolute_X, 7),

      Decl(.CPX, .Immediate, 2),
      Decl(.SBC, .Indirect_X, 6),
      Decl(.NOP, .Immediate, 2),
      Decl(.ISC, .Indirect_X, 8),
      Decl(.CPX, .ZeroPage, 3),
      Decl(.SBC, .ZeroPage, 3),
      Decl(.INC, .ZeroPage, 5),
      Decl(.ISC, .ZeroPage, 5),
      Decl(.INX, .Implied, 2),
      Decl(.SBC, .Immediate, 2),
      Decl(.NOP, .Implied, 2),
      Decl(.SBC, .Immediate, 2),
      Decl(.CPX, .Absolute, 4),
      Decl(.SBC, .Absolute, 4),
      Decl(.INC, .Absolute, 6),
      Decl(.ISC, .Absolute, 6),

      Decl(.BEQ, .Relative, 2, true),
      Decl(.SBC, .Indirect_Y, 5, true),
      Decl(.STP, .Implied),
      Decl(.ISC, .Indirect_Y, 8),
      Decl(.NOP, .ZeroPage_X, 4),
      Decl(.SBC, .ZeroPage_X, 4),
      Decl(.INC, .ZeroPage_X, 6),
      Decl(.ISC, .ZeroPage_X, 6),
      Decl(.SED, .Implied, 2),
      Decl(.SBC, .Absolute_Y, 4, true),
      Decl(.NOP, .Implied, 2),
      Decl(.ISC, .Absolute_Y, 7),
      Decl(.NOP, .Absolute_X, 4, true),
      Decl(.SBC, .Absolute_X, 4, true),
      Decl(.INC, .Absolute_X, 7),
      Decl(.ISC, .Absolute_X, 7),
    ]

    static func decode(opcode: UInt8) -> Decl {
        return table[Int(opcode)]
    }
}

// Instruction
struct Inst {
    let opcode: UInt8
    let operand: Operand
    let decl: Decl
}

extension Inst: CustomStringConvertible {
    var description: String {
        return "\(opcode.hex) \(operand) : \(decl.mnemonic) \(operand.format(mode: decl.mode))"
    }
}

extension Operand {
    func format(mode: Addressing) -> String {
        switch mode {
        case .Absolute: return "$\(word.hex)   "
        case .Absolute_X: return "$\(word.hex), X"
        case .Absolute_Y: return "$\(word.hex), Y"
        case .Accumulator: return "A       "
        case .Immediate: return "#$\(byte.hex)    "
        case .Implied: return "        "
        case .Indirect: return "($\(word.hex)) "
        case .Indirect_X: return "($\(byte.hex), X)"
        case .Indirect_Y: return "($\(byte.hex)), Y"
        case .Relative: return "$\(byte.hex)     "
        case .ZeroPage: return "$\(byte.hex)     "
        case .ZeroPage_X: return "$\(byte.hex), X  "
        case .ZeroPage_Y: return "$\(byte.hex), Y  "
        }
    }
}

protocol Result: AnyObject {
    var value: UInt8 { get set }
}
