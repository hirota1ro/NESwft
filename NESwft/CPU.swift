//
//  CPU.swift
//  NESwft
//
//  Created by HIROTA Ichiro on 2018/10/22.
//  Copyright © 2018 HIROTA Ichiro. All rights reserved.
//

import Foundation

// RP2A03 (1.79MHz) (MOS6502 + APU + DAC)
class CPU {
    var reg: Register
    let mem: Memory
    weak var callback: CPUCallback? = nil

    init(reg: Register, mem: Memory) {
        self.reg = reg
        self.mem = mem
    }
}

protocol CPUCallback: AnyObject {
    func halt(cpu: CPU)
}

// CPU cycle: fetch, decode, exec
extension CPU {

    /** fetch phase
     * @return opcode
     * [precondition]
     * PC ← point to current opcode
     * [side effect]
     * PC ← point to operand
     */
    func fetch() -> UInt8 {
        defer { reg.pc &+= 1 }
        return mem[reg.pc]
    }

    /** decode phase
     * @param opcode byte code
     * @return instruction (nil: undefined opcode)
     * [precondition]
     * PC ← point to operand
     * [side effect]
     * PC ← point to next opcode
     */
    func decode(opcode: UInt8) -> Inst {
        let decl = Decoder.decode(opcode: opcode)
        let opr = operand(at: reg.pc, with: decl.mode)
        reg.pc &+= opr.size
        return Inst(opcode: opcode, operand: opr, decl: decl)
    }

    /** load effective address
     * @param inst instruction
     * @return context contains effective address
     */
    func context(inst: Inst) -> Context {
        return Context(cpu: self, inst: inst)
    }

    /** execution phase
     * @param context contains effective address
     * [precondition]
     * PC ← point to next opcode
     */
    func exec(context ctx: Context) {
        switch ctx.inst.decl.mnemonic {
        case .ADC: ADC(ctx.data)
        case .AHX: AHX(ctx.address)
        case .ALR: ALR(ctx.data)
        case .ANC: ANC(ctx.data)
        case .AND: AND(ctx.data)
        case .ARR: ARR(ctx.data)
        case .ASL: ASL(ctx.result, ctx.data)
        case .AXS: AXS(ctx.data)
        case .BCC: BCC(ctx.address)
        case .BCS: BCS(ctx.address)
        case .BEQ: BEQ(ctx.address)
        case .BIT: BIT(ctx.data)
        case .BMI: BMI(ctx.address)
        case .BNE: BNE(ctx.address)
        case .BPL: BPL(ctx.address)
        case .BRK: BRK()
        case .BVC: BVC(ctx.address)
        case .BVS: BVS(ctx.address)
        case .CLC: CLC()
        case .CLD: CLD()
        case .CLI: CLI()
        case .CLV: CLV()
        case .CMP: CMP(ctx.data)
        case .CPX: CPX(ctx.data)
        case .CPY: CPY(ctx.data)
        case .DCP: DCP(ctx.address, ctx.data)
        case .DEC: DEC(ctx.address, ctx.data)
        case .DEX: DEX()
        case .DEY: DEY()
        case .EOR: EOR(ctx.data)
        case .INC: INC(ctx.address, ctx.data)
        case .INX: INX()
        case .INY: INY()
        case .ISC: ISC(ctx.address, ctx.data)
        case .JMP: JMP(ctx.addressJMP)
        case .JSR: JSR(ctx.address)
        case .LAS: LAS(ctx.data)
        case .LAX: LAX(ctx.data)
        case .LDA: LDA(ctx.data)
        case .LDX: LDX(ctx.data)
        case .LDY: LDY(ctx.data)
        case .LSR: LSR(ctx.result, ctx.data)
        case .NOP: NOP()
        case .ORA: ORA(ctx.data)
        case .PHA: PHA()
        case .PHP: PHP()
        case .PLA: PLA()
        case .PLP: PLP()
        case .RLA: RLA(ctx.address, ctx.data)
        case .ROL: ROL(ctx.result, ctx.data)
        case .ROR: ROR(ctx.result, ctx.data)
        case .RRA: RRA(ctx.address, ctx.data)
        case .RTI: RTI()
        case .RTS: RTS()
        case .SAX: SAX(ctx.address)
        case .SBC: SBC(ctx.data)
        case .SEC: SEC()
        case .SED: SED()
        case .SEI: SEI()
        case .SHX: SHX(ctx.address)
        case .SHY: SHY(ctx.address)
        case .SLO: SLO(ctx.address, ctx.data)
        case .SRE: SRE(ctx.address, ctx.data)
        case .STA: STA(ctx.address)
        case .STP: STP()
        case .STX: STX(ctx.address)
        case .STY: STY(ctx.address)
        case .TAS: TAS(ctx.address)
        case .TAX: TAX()
        case .TAY: TAY()
        case .TSX: TSX()
        case .TXA: TXA()
        case .TXS: TXS()
        case .TYA: TYA()
        case .XAA: XAA(ctx.data)
        }
    }

    /**
     * @param at point to operand (point to opcode + 1)
     * @param with addressing mode
     * @return operand
     */
    func operand(at addr: UInt16, with mode: Addressing) -> Operand {
        switch mode {
        case .Accumulator, .Implied:
            return .void
        case .Immediate, .Indirect_X, .Indirect_Y, .Relative, .ZeroPage, .ZeroPage_X, .ZeroPage_Y:
            return .byte(mem[addr])
        case .Absolute, .Absolute_X, .Absolute_Y, .Indirect:
            return .word(mem[word: addr])
        }
    }

    func jmpAddr(_ mode: Addressing, _ opr: Operand) -> UInt16 {
        switch mode {
        case .Absolute:
            return opr.word
        case .Indirect:
            let addr = opr.word
            let lo = mem[addr]
            let hi = mem[(addr & 0xFF00) | (((addr & 0x00FF) + 1) & 0x00FF)] // !<trap>
            return UInt16(lo: lo, hi: hi)
        default:
            fatalError("JMP Addressing mode is Indirect and Absolute obly")
        }
    }

    func addr(_ mode: Addressing, _ opr: Operand) -> UInt16 {
        switch mode {
        case .Absolute:
            return opr.word
        case .Absolute_X:
            return opr.word &+ UInt16(reg.x)
        case .Absolute_Y:
            return opr.word &+ UInt16(reg.y)
        case .Accumulator:
            return UInt16(reg.a)
        case .Immediate:
            return UInt16(opr.byte)
        case .Implied:
            return 0
        case .Indirect:
            return mem[word: opr.word]
        case .Indirect_X:
            return mem[pagebound: UInt16(opr.byte &+ reg.x)]
        case .Indirect_Y:
            return mem[pagebound: UInt16(opr.byte)] &+ UInt16(reg.y)
        case .Relative:
            return UInt16(bitPattern: Int16(Int8(bitPattern: opr.byte))) &+ reg.pc
        case .ZeroPage:
            return UInt16(opr.byte)
        case .ZeroPage_X:
            return UInt16(opr.byte &+ reg.x)
        case .ZeroPage_Y:
            return UInt16(opr.byte &+ reg.y)
        }
    }

    func data(_ mode: Addressing, _ aaaa: UInt16) -> UInt8 {
        switch mode {
        case .Accumulator, .Immediate, .Implied:
            return aaaa.lo
        default:
            return mem[aaaa]
        }
    }

    // for ASL, ROL, LSR, ROR
    func result(_ mode: Addressing, _ aaaa: UInt16) -> Result {
        switch mode {
        case .Accumulator:
            return Accumulator(cpu: self)
        case .ZeroPage, .ZeroPage_X, .Absolute, .Absolute_X:
            return Store(mem: mem, addr: aaaa)
        default:
            return Null()
        }
    }
}

// execution context
extension CPU {
    class Context {
        let cpu: CPU
        let inst: Inst
        init(cpu: CPU, inst: Inst) {
            self.cpu = cpu
            self.inst = inst
        }
        var cacheAddr: UInt16? = nil
        var cacheData: UInt8? = nil
    }
}

extension CPU.Context: CustomStringConvertible {
    var description: String {
        return "\(address.hex) \(data.hex)"
    }
}

extension CPU.Context {
    var address: UInt16 {
        if let aaaa = cacheAddr {
            return aaaa
        } else {
            let aaaa = cpu.addr(inst.decl.mode, inst.operand)
            cacheAddr = aaaa
            return aaaa
        }
    }
    var data: UInt8 {
        if let dd = cacheData {
            return dd
        } else {
            let dd = cpu.data(inst.decl.mode, address)
            cacheData = dd
            return dd
        }
    }
    var result: Result {
        return cpu.result(inst.decl.mode, address)
    }
    // <!>trap
    var addressJMP: UInt16 {
        if let aaaa = cacheAddr {
            return aaaa
        } else {
            let aaaa = cpu.jmpAddr(inst.decl.mode, inst.operand)
            cacheAddr = aaaa
            return aaaa
        }
    }
}

extension CPU {
    class Accumulator: Result {
        let cpu: CPU
        init(cpu: CPU) {
            self.cpu = cpu
        }
        var value: UInt8 {
            get { return cpu.reg.a }
            set { cpu.reg.a = newValue }
        }
    }

    class Store: Result {
        let mem: Memory
        let addr: UInt16
        init(mem: Memory, addr: UInt16) {
            self.mem = mem
            self.addr = addr
        }
        var value: UInt8 {
            get { return mem[addr] }
            set { mem[addr] = newValue }
        }
    }

    class Null: Result {
        var value: UInt8 {
            get { return 0 }
            set {}
        }
    }
}

// Interrupt
extension CPU {
    enum Interrupt: UInt16 {
        case NMI = 0xFFFA
        case RESET = 0xFFFC
        //case IRQ = 0xFFFE
        case BRK = 0xFFFE
    }

    func reset() {
        reg.p.i = true
        reg.pc = mem[word: Interrupt.RESET.rawValue]
        reg.s -= 3 // S was decremented by 3 (but nothing was written to the stack)
    }

    func NMI() {
        reg.p.b = false
        push(word: reg.pc)
        push((reg.p.rawValue | 0b0010_0000) & 0b1110_1111) // <!>trap bit5←1, bit4←0
        reg.p.i = true
        reg.pc = mem[word: Interrupt.NMI.rawValue]
    }

    func IRQ() {
        guard !reg.p.i else { return }
        reg.p.b = false
        push(word: reg.pc)
        push((reg.p.rawValue | 0b0010_0000) & 0b1110_1111) // <!>trap bit5←1, bit4←0
        reg.p.i = true
        reg.pc = mem[word: Interrupt.BRK.rawValue]
    }

    func BRK() {
        guard !reg.p.i else { return }
        reg.p.b = true
        reg.pc &+= 1
        push(word: reg.pc)
        push(reg.p.rawValue | 0b0011_0000) // <!>trap bit5←1, bit4←1
        reg.p.i = true
        reg.pc = mem[word: Interrupt.BRK.rawValue]
    }

    func RTI() {
        reg.p.rawValue = pull()
        reg.pc = pop()
    }
}

// Stack
extension CPU {

    func push(_ dd: UInt8) {
        let aaaa = UInt16(lo: reg.s, hi: 0x01)
        mem[aaaa] = dd
        reg.s &-= 1
    }

    func pull() -> UInt8 {
        reg.s &+= 1
        let aaaa = UInt16(lo: reg.s, hi: 0x01)
        return mem[aaaa]
    }

    func push(word aaaa: UInt16) {
        push(aaaa.hi)
        push(aaaa.lo)
    }

    func pop() -> UInt16 {
        let lo = pull()
        let hi = pull()
        return UInt16(lo: lo, hi: hi)
    }

    func PHA() {
        push(reg.a)
    }

    func PLA() {
        reg.a = pull()
        reg.p.n = reg.a.nega
        reg.p.z = reg.a.zero
    }

    func PHP() {
        push(reg.p.rawValue | 0b0011_0000) // <!>trap bit5←1, bit4←1
    }

    func PLP() {
        reg.p.rawValue = pull()
    }
}

// Arithmetic Operation
extension CPU {

    func ADC(_ dd: UInt8) {
        let aa = reg.a
        let aaaa = UInt16(aa)
        let dddd = UInt16(dd)
        let rrrr = aaaa &+ dddd &+ reg.p.c.word
        let rr = rrrr.lo
        reg.p.n = rr.nega
        reg.p.v = (aa ^ dd).posi && (aa ^ rr).nega
        reg.p.z = rr.zero
        reg.p.c = 0xFF < rrrr
        reg.a = rr
    }

    func SBC(_ dd: UInt8) {
        let aa = reg.a
        let aaaa = UInt16(aa)
        let dddd = UInt16(dd)
        let rrrr = aaaa &- dddd &- (!reg.p.c).word
        let rr = rrrr.lo
        reg.p.n = rr.nega
        reg.p.v = (aa ^ dd).nega && (aa ^ rr).nega
        reg.p.z = rr.zero
        reg.p.c = rrrr <= 0xFF
        reg.a = rr
    }
}

// Logical Operation
extension CPU {

    func AND(_ dd: UInt8) {
        reg.a &= dd
        reg.p.n = reg.a.nega
        reg.p.z = reg.a.zero
    }

    func ORA(_ dd: UInt8) {
        reg.a |= dd
        reg.p.n = reg.a.nega
        reg.p.z = reg.a.zero
    }

    func EOR(_ dd: UInt8) {
        reg.a ^= dd
        reg.p.n = reg.a.nega
        reg.p.z = reg.a.zero
    }

    func BIT(_ dd: UInt8) {
        reg.p.n = dd.nega
        reg.p.v = dd[bit: 6].bool
        reg.p.z = (reg.a & dd).zero
    }
}

// Rotate, Shift
extension CPU {

    func ASL(_ r: Result, _ dd: UInt8) {
        let c = dd[bit: 7]
        let rr = dd << 1
        reg.p.n = rr.nega
        reg.p.z = rr.zero
        reg.p.c = c.bool
        r.value = rr
    }

    func LSR(_ r: Result, _ dd: UInt8) {
        let c = dd[bit: 0]
        let rr = dd >> 1
        reg.p.n = rr.nega
        reg.p.z = rr.zero
        reg.p.c = c.bool
        r.value = rr
    }

    func ROL(_ r: Result, _ dd: UInt8) {
        let c = dd[bit: 7]
        let cc = reg.p.c.byte
        let rr = (dd << 1) | cc
        reg.p.n = rr.nega
        reg.p.z = rr.zero
        reg.p.c = c.bool
        r.value = rr
    }

    func ROR(_ r: Result, _ dd: UInt8) {
        let c = dd[bit: 0]
        let cc  = reg.p.c.byte << 7
        let rr = (dd >> 1) | cc
        reg.p.n = rr.nega
        reg.p.z = rr.zero
        reg.p.c = c.bool
        r.value = rr
    }
}

// Branch
extension CPU {

    func BCC(_ aaaa: UInt16) {
        if !reg.p.c {
            reg.pc = aaaa
        }
    }

    func BCS(_ aaaa: UInt16) {
        if reg.p.c {
            reg.pc = aaaa
        }
    }

    func BEQ(_ aaaa: UInt16) {
        if reg.p.z {
            reg.pc = aaaa
        }
    }

    func BNE(_ aaaa: UInt16) {
        if !reg.p.z {
            reg.pc = aaaa
        }
    }

    func BVC(_ aaaa: UInt16) {
        if !reg.p.v {
            reg.pc = aaaa
        }
    }

    func BVS(_ aaaa: UInt16) {
        if reg.p.v {
            reg.pc = aaaa
        }
    }

    func BPL(_ aaaa: UInt16) {
        if !reg.p.n {
            reg.pc = aaaa
        }
    }

    func BMI(_ aaaa: UInt16) {
        if reg.p.n {
            reg.pc = aaaa
        }
    }
}

// Jump
extension CPU {

    func JMP(_ aaaa: UInt16) {
        reg.pc = aaaa
    }

    func JSR(_ aaaa: UInt16) {
        let rrrr = reg.pc &- 1 // <!>trap -1
        push(word: rrrr)
        reg.pc = aaaa
    }

    func RTS() {
        let rrrr = pop()
        reg.pc = rrrr &+ 1 // <!>trap +1
    }
}

// Comparation
extension CPU {

    func CMP(_ dd: UInt8) {
        let rrrr = UInt16(reg.a) &- UInt16(dd)
        let rr = rrrr.lo
        reg.p.n = rr.nega
        reg.p.z = rr.zero
        reg.p.c = !rrrr[bit: 15].bool
    }

    func CPX(_ dd: UInt8) {
        let rrrr = UInt16(reg.x) &- UInt16(dd)
        let rr = rrrr.lo
        reg.p.n = rr.nega
        reg.p.z = rr.zero
        reg.p.c = !rrrr[bit: 15].bool
    }

    func CPY(_ dd: UInt8) {
        let rrrr = UInt16(reg.y) &- UInt16(dd)
        let rr = rrrr.lo
        reg.p.n = rr.nega
        reg.p.z = rr.zero
        reg.p.c = !rrrr[bit: 15].bool
    }
}

// Increment, Deccrement
extension CPU {

    func INC(_ aaaa: UInt16, _ dd: UInt8) {
        let rr = dd &+ 1
        reg.p.n = rr.nega
        reg.p.z = rr.zero
        mem[aaaa] = rr
    }

    func DEC(_ aaaa: UInt16, _ dd: UInt8) {
        let rr = dd &- 1
        reg.p.n = rr.nega
        reg.p.z = rr.zero
        mem[aaaa] = rr
    }

    func INX() {
        reg.x &+= 1
        reg.p.n = reg.x.nega
        reg.p.z = reg.x.zero
    }

    func DEX() {
        reg.x &-= 1
        reg.p.n = reg.x.nega
        reg.p.z = reg.x.zero
    }

    func INY() {
        reg.y &+= 1
        reg.p.n = reg.y.nega
        reg.p.z = reg.y.zero
    }

    func DEY() {
        reg.y &-= 1
        reg.p.n = reg.y.nega
        reg.p.z = reg.y.zero
    }
}

// Flags
extension CPU {

    func CLC() {
        reg.p.c = false
    }

    func SEC() {
        reg.p.c = true
    }

    func CLI() {
        reg.p.i = false
    }

    func SEI() {
        reg.p.i = true
    }

    func CLD() {
        reg.p.d = false
    }

    func SED() {
        reg.p.d = true
    }

    func CLV() {
        reg.p.v = false
    }
}

// Load, Store
extension CPU {

    func LDA(_ dd: UInt8) {
        reg.a = dd
        reg.p.n = reg.a.nega
        reg.p.z = reg.a.zero
    }

    func LDX(_ dd: UInt8) {
        reg.x = dd
        reg.p.n = reg.x.nega
        reg.p.z = reg.x.zero
    }

    func LDY(_ dd: UInt8) {
        reg.y = dd
        reg.p.n = reg.y.nega
        reg.p.z = reg.y.zero
    }

    func STA(_ aaaa: UInt16) {
        mem[aaaa] = reg.a
    }

    func STX(_ aaaa: UInt16) {
        mem[aaaa] = reg.x
    }

    func STY(_ aaaa: UInt16) {
        mem[aaaa] = reg.y
    }
}

// Transfer
extension CPU {

    func TAX() {
        reg.x = reg.a
        reg.p.n = reg.x.nega
        reg.p.z = reg.x.zero
    }

    func TXA() {
        reg.a = reg.x
        reg.p.n = reg.a.nega
        reg.p.z = reg.a.zero
    }

    func TAY() {
        reg.y = reg.a
        reg.p.n = reg.y.nega
        reg.p.z = reg.y.zero
    }

    func TYA() {
        reg.a = reg.y
        reg.p.n = reg.a.nega
        reg.p.z = reg.a.zero
    }

    func TSX() {
        reg.x = reg.s
        reg.p.n = reg.x.nega
        reg.p.z = reg.x.zero
    }

    func TXS() {
        reg.s = reg.x
    }
}

extension CPU {
    func NOP() {}
}

// Unofficial Opcodes
extension CPU {
    func SLO(_ aaaa: UInt16, _ dd: UInt8) {
        // SLO {adr} = ASL {adr} + ORA {adr}
        ASL(Store(mem: mem, addr: aaaa), dd)
        ORA(mem[aaaa])
    }
    func RLA(_ aaaa: UInt16, _ dd: UInt8) {
        // RLA {adr} = ROL {adr} + AND {adr}
        ROL(Store(mem: mem, addr: aaaa), dd)
        AND(mem[aaaa])
    }
    func SRE(_ aaaa: UInt16, _ dd: UInt8) {
        // SRE {adr} = LSR {adr} + EOR {adr}
        LSR(Store(mem: mem, addr: aaaa), dd)
        EOR(mem[aaaa])
    }
    func RRA(_ aaaa: UInt16, _ dd: UInt8) {
        // RRA {adr} = ROR {adr} + ADC {adr}
        ROR(Store(mem: mem, addr: aaaa), dd)
        ADC(mem[aaaa])
    }
    func SAX(_ aaaa: UInt16) {
        // SAX {adr} = store A&X into {adr}
        mem[aaaa] = reg.a & reg.x
    }
    func LAX(_ dd: UInt8) {
        // LAX {adr} = LDA {adr} + LDX {adr}
        LDA(dd)
        LDX(dd)
    }
    func DCP(_ aaaa: UInt16, _ dd: UInt8) {
        // DCP {adr} = DEC {adr} + CMP {adr}
        DEC(aaaa, dd)
        CMP(mem[aaaa])
    }
    func ISC(_ aaaa: UInt16, _ dd: UInt8) {
        // ISC {adr} = INC {adr} + SBC {adr}
        INC(aaaa, dd)
        SBC(mem[aaaa])
    }
    func ANC(_ dd: UInt8) {
        // (0B) ANC #{imm} = AND #{imm} + (ASL)
        // (2B) ANC #{imm} = AND #{imm} + (ROL)
        AND(dd)
        ASL(Null(), dd)
    }
    func ALR(_ dd: UInt8) {
        // ALR #{imm} = AND #{imm} + LSR
        AND(dd)
        LSR(Null(), dd)
    }
    func ARR(_ dd: UInt8) {
        // ARR #{imm} = AND #{imm} + ROR
        AND(dd)
        ROR(Null(), dd)
    }
    func XAA(_ dd: UInt8) {
        // XAA #{imm} = TXA + AND #{imm}
        TXA()
        AND(dd)
    }
    func AXS(_ dd: UInt8) {
        // AXS #{imm} = A&X minus #{imm} into X
        reg.x = (reg.a & reg.x) &- dd
    }
    func AHX(_ aaaa: UInt16) {
        // AHX {adr} = stores A&X&H into {adr}
        let hh = aaaa.hi
        mem[aaaa] = reg.a & reg.x & hh
    }
    func SHY(_ aaaa: UInt16) {
        // SHY {adr} = stores Y&H into {adr}
        let hh = aaaa.hi
        mem[aaaa] = reg.y & hh
    }
    func SHX(_ aaaa: UInt16) {
        // SHX {adr} = stores X&H into {adr}
        let hh = aaaa.hi
        mem[aaaa] = reg.x & hh
    }
    func TAS(_ aaaa: UInt16) {
        // TAS {adr} = stores A&X into S and A&X&H into {adr}
        let hh = aaaa.hi
        reg.s = reg.a & reg.x
        mem[aaaa] = reg.a & reg.x & hh
    }
    func LAS(_ dd: UInt8) {
        // LAS {adr} = stores {adr}&S into A, X and S
        let ss = dd & reg.s
        reg.a = ss
        reg.x = ss
        reg.s = ss
    }
    func STP() {
        callback?.halt(cpu: self)
    }
}

// Disassemble
extension CPU {

    func disassemble(opcode: UInt8, from addr: UInt16) -> Inst {
        let decl = Decoder.decode(opcode: opcode)
        let opr = operand(at: addr, with: decl.mode)
        return Inst(opcode: opcode, operand: opr, decl: decl)
    }
}
