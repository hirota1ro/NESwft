//
//  EmuViewController.swift
//  NESwft
//
//  Created by HIROTA Ichiro on 2018/10/22.
//  Copyright © 2018 HIROTA Ichiro. All rights reserved.
//

import UIKit

class EmuViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var label: UILabel!

    var url: URL?

    var workerQueue: OperationQueue!
    var imagingQueue: OperationQueue!
    var frameTimer: Timer?
    var beatTimer: Timer?

    var nes: NES?

    var cpuclks: Int = 0
    var imageCount = 0
    var running = true

    let FPS = 30 // frame per 1 sec
    var INTERVAL_SEC: Double { return 1.0/Double(FPS) } // (sec)
    let CPU_Hz = 1790000 // 1.79 MHz = 1790000 Hz
    var CPU_CLOCK_SEC: Double{ return 1.0/Double(CPU_Hz) } // (sec)

    lazy var clocksPerFrame = CPU_Hz / FPS // clocks per 1 frame

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.delegate = self

        workerQueue = OperationQueue(name: "Worker", maxConcurrentOperationCount: 1)
        imagingQueue = OperationQueue(name: "Imaging", maxConcurrentOperationCount: 1)

        indicator.startAnimating()
        workerQueue.addOperation {
            self.load()
            OperationQueue.main.addOperation {
                self.indicator.stopAnimating()
                self.start()
            }
        }
    }

    func info(_ s: String) {
        OperationQueue.main.addOperation {
            self.label.text = s
        }
    }

    func load() {
        guard let url = url else {
            info("no URL")
            return
        }
        guard let cartridge = Cartridge(url: url) else {
            info("invalid \(url.lastPathComponent)")
            return
        }
        guard let nes = cartridge.createNES() else {
            info("unavailable \(url.lastPathComponent)")
            return
        }
        nes.ppu.callback = self
        nes.cpu.callback = self
        nes.cpu.reset()
        self.nes = nes
    }

    func start() {
        self.navigationItem.title = url?.deletingPathExtension().lastPathComponent
        guard let nes = nes else {
            return
        }
        frameTimer = Timer.scheduledTimer(withTimeInterval: INTERVAL_SEC, repeats: true) { _ in
            if self.running {
                self.workerQueue.addOperation {
                    self.proceed(nes)
                }
            }
        }
        beatTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            OperationQueue.main.addOperation {
                defer { self.imageCount = 0 }
                self.label.text = "\(self.imageCount) FPS"
            }
        }
    }

    func update(_ ppu: PPU) {
        if let img = ppu.bitmap.image {
            OperationQueue.main.addOperation {
                self.imageView.image = img
                self.imageCount += 1
            }
        }
    }

    func proceed(_ nes: NES) {
        let start = Date()
        var c = 0
        while c < clocksPerFrame {
            c += tick(nes)
        }
        let elapsed = Date().timeIntervalSince(start)
        // actual clock time (sec) ← actual time (sec) / c
        let actual = elapsed / Double(c)
        // clock count ← frame time (sec) / actual clock time (sec)
        let cc = INTERVAL_SEC / actual
        // average
        clocksPerFrame = (clocksPerFrame + Int(cc)) / 2
    }

    func tick(_ nes: NES) -> Int {
        let cpu = nes.cpu
        let ppu = nes.ppu
        let dma = nes.dma
        //
        guard running else {
            return 999
        }
        //
        let opcode = cpu.fetch()
        let inst = cpu.decode(opcode: opcode)
        let ctx = cpu.context(inst: inst)
        dma.clocks = 0
        cpu.exec(context: ctx)
        let c = inst.decl.clocks + dma.clocks
        ppu.step(clocks: c * 3)
        cpuclks += c
        return c
    }
}

extension EmuViewController: CPUCallback {
    func halt(cpu: CPU) {
        running = false
    }
}

extension EmuViewController: PPUCallback {

    func vBlankBegin(ppu: PPU, genNMI: Bool) {
        cpuclks = 0
        if genNMI {
            nes!.cpu.NMI() // TODO (?) clocks
        }
        imagingQueue.addOperation {
            self.update(ppu)
        }
    }

    func vBlankEnd(ppu: PPU) {
        // log.info("# cpuclks=\(cpuclks)")
    }
}

// from storyboard
extension EmuViewController {

    @IBAction func tapActionItem(_ sender: UIBarButtonItem) {
        guard let image = imageView.image else {
            info("no image")
            return
        }
        guard let data = image.pngData() else {
            info("no data")
            return
        }
        guard let dirURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            info("no dir")
            return
        }
        guard let url = url else {
            info("no url")
            return
        }
        let name = url.deletingPathExtension().appendingPathExtension("png").lastPathComponent
        let fileURL = dirURL.appendingPathComponent(name)
        do {
            try data.write(to: fileURL)
        } catch let error {
            print("error=\(error)")
        }
        print(fileURL)

        let dic = UIDocumentInteractionController(url: fileURL)
        let ok = dic.presentOpenInMenu(from: sender, animated: true)
        print("ok=\(ok)")
    }

    @IBAction func tapPauseButton(_ sender: UIButton) {
    }

    @IBAction func tapResetButton(_ sender: UIButton) {
        if let nes = nes {
            workerQueue.addOperation {
                nes.cpu.reset()
                nes.ppu.reset()
                nes.apu.reset()
                self.running = true
            }
        }
    }

    @IBAction func tapShotButton(_ sender: UIButton) {
    }

    @IBAction func tapDumpButton(_ sender: UIButton) {
        if let ppu = nes?.ppu {
            dump(ppu: ppu)
        }
    }

    @IBAction func downA(_ sender: UIButton) { nes?.pad.con1.a = true }

    @IBAction func upA(_ sender: UIButton) { nes?.pad.con1.a = false }

    @IBAction func downB(_ sender: UIButton) { nes?.pad.con1.b = true }

    @IBAction func upB(_ sender: UIButton) { nes?.pad.con1.b = false }

    @IBAction func downSTART(_ sender: UIButton) { nes?.pad.con1.start = true }

    @IBAction func upSTART(_ sender: UIButton) { nes?.pad.con1.start = false }

    @IBAction func downSELECT(_ sender: UIButton) { nes?.pad.con1.select = true }

    @IBAction func upSELECT(_ sender: UIButton) { nes?.pad.con1.select = false }

    @IBAction func downUP(_ sender: UIButton) { nes?.pad.con1.up = true }

    @IBAction func upUP(_ sender: UIButton) { nes?.pad.con1.up = false }

    @IBAction func downDOWN(_ sender: UIButton) { nes?.pad.con1.down = true }

    @IBAction func upDOWN(_ sender: UIButton) { nes?.pad.con1.down = false }

    @IBAction func downLEFT(_ sender: UIButton) { nes?.pad.con1.left = true }

    @IBAction func upLEFT(_ sender: UIButton) { nes?.pad.con1.left = false }

    @IBAction func downRIGHT(_ sender: UIButton) { nes?.pad.con1.right = true }

    @IBAction func upRIGHT(_ sender: UIButton) { nes?.pad.con1.right = false }
}

extension EmuViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is FilesViewController {
            navigationController.delegate = nil
            frameTimer?.invalidate()
            beatTimer?.invalidate()
            workerQueue.cancelAllOperations()
            imagingQueue.cancelAllOperations()
            running = false
            if let nes = nes {
                nes.cpu.callback = nil
                nes.ppu.callback = nil
            }
        }
    }
}

extension EmuViewController {

    func dump(ppu: PPU) {
        print("PPU.stat=\(ppu.stat) $\(ppu.stat.rawValue.hex)")
        print("PPU.ctrl=\(ppu.ctrl) $\(ppu.ctrl.rawValue.hex)")
        print("PPU.mask=\(ppu.mask) $\(ppu.mask.rawValue.hex)")
        print("PPU scroll=\(ppu.scroll)")
        print("-- BG --\n\(ppu.vram)")
        print("-- Palette Memory (RAW) --\n\(ppu.palmem.data.pageDump(prefix: 0x3F00))")
        print("-- Palette Memory --\n\(ppu.palmem)")
        print("-- Sprite Memory (RAW) --\n\(ppu.sprmem)")
        let sprites = ppu.sprites
        print("-- Sprite --\n\(sprites.map({ $0.description }).joined(separator: "\n"))")
        let a = Set(sprites.map({ $0.p }))
        let b = a.map({ ($0, ppu.pattern8(sp: $0)) })
        for (i,p) in b {
            print("----- \(i.hex) ------\n\(p)")
        }
    }

    func disassemble(cpu: CPU) {
        let nmiAddr = cpu.mem[word: CPU.Interrupt.NMI.rawValue]
        print("| NMI=\(nmiAddr.hex)")
        print(cpu.disassembleList(from: nmiAddr, to: nmiAddr+0x1000).joined(separator: "\n"))
        let resetAddr = cpu.mem[word: CPU.Interrupt.RESET.rawValue]
        print("| RESET=\(resetAddr.hex)")
        print(cpu.disassembleList(from: resetAddr, to: resetAddr+0x1000).joined(separator: "\n"))
        let brkAddr = cpu.mem[word: CPU.Interrupt.BRK.rawValue]
        print("| BRK=\(brkAddr.hex)")
        print(cpu.disassembleList(from: brkAddr, to: brkAddr+0x1000).joined(separator: "\n"))
    }
}

// dump disassemble list
extension CPU {
    func disassembleList(from: UInt16, to: UInt16) -> [String] {
        var a: [String] = []
        var addr = from
        repeat {
            let aaaa = addr
            let opcode = self.mem[addr]
            addr &+= 1
            let inst = self.disassemble(opcode: opcode, from: addr)
            a.append("\(aaaa.hex): \(inst)")
            addr &+= inst.operand.size
        } while addr < to
        return a
    }
}

extension Bitmap {

    var cgImage: CGImage? {
        let bitsPerPixel = bitsPerComponent * numberOfComponents
        let bytesPerPixel = bitsPerPixel / 8
        let provider = CGDataProvider(data: data as CFData)
        return CGImage(width: width,
                       height: height,
                       bitsPerComponent: bitsPerComponent,
                       bitsPerPixel: bitsPerPixel,
                       bytesPerRow: width * bytesPerPixel,
                       space: CGColorSpaceCreateDeviceRGB(),
                       bitmapInfo: [],
                       provider: provider!,
                       decode: nil,
                       shouldInterpolate: false,
                       intent: .defaultIntent)
    }

    var image: UIImage? {
        if let img = cgImage {
            return UIImage(cgImage: img)
        }
        return nil
    }
}

extension OperationQueue {
    convenience init(name: String, maxConcurrentOperationCount: Int) {
        self.init()
        self.name = name
        self.maxConcurrentOperationCount = maxConcurrentOperationCount
    }
}
