//
//  FKSwiftSectionFunction.swift
//  FKSwiftSectionFunction
//
//  Created by xxx
//

import MachO
import Foundation
@_implementationOnly import FuckKit

public class FKSwiftSectionFunction {
    lazy var exportedSymbols = [String : UnsafeMutableRawPointer?]()
    lazy var organizedSymbols = [String : [UnsafeMutableRawPointer?]]()
    var namespace : String
    
    static let workQueue = DispatchQueue(label: "swift.function.queue")
    
    public convenience init(namespace: String) {
        self.init(privately: namespace)
        setup()
    }

    private init(privately: String) {
        self.namespace = privately
    }
    
    static let `default` = FKSwiftSectionFunction(namespace: "FuckKit")
    
    lazy var fullNamespace = "_" + namespace + "."
    
    static func dumpAllExportedSymbol() {
        _dyld_register_func_for_add_image { (image, slide) in
            var info = Dl_info()
            if (dladdr(image, &info) == 0) {
                return
            }
            if (!String(cString: info.dli_fname).hasPrefix(Bundle.main.bundlePath)) {
                return
            }
            let exportedSymbols = FKSwiftSectionFunction.default.getExportedSymbols(image: image, slide: slide)
            exportedSymbols.forEach { (key, symbol) in
                FKSwiftSectionFunction.workQueue.sync {
                    FKSwiftSectionFunction.default.addSymbol(key: key, symbol: symbol)
                }
            }
        }
    }
    
    func setup() {
        for i in 0..<_dyld_image_count() {
            let exportedSymbols = getExportedSymbols(image: _dyld_get_image_header(i), slide: _dyld_get_image_vmaddr_slide(i))
            exportedSymbols.forEach { (key, symbol) in
                FKSwiftSectionFunction.workQueue.sync {
                    addSymbol(key: key, symbol: symbol)
                }
            }
        }
    }
    
    func addSymbol(key: String, symbol: UnsafeMutableRawPointer?) {
        self.exportedSymbols[key] = symbol
    }
    
    static func readUleb128(p: inout UnsafeMutablePointer<UInt8>, end: UnsafeMutablePointer<UInt8>) -> UInt64 {
        var result: UInt64 = 0
        var bit = 0
        var read_next = true
        
        repeat {
            if p == end {
                assert(false, "malformed uleb128")
            }
            let slice = UInt64(p.pointee & 0x7f)
            if bit > 63 {
                assert(false, "uleb128 too big for uint64")
            } else {
                result |= (slice << bit)
                bit += 7
            }
            read_next = (p.pointee & 0x80) != 0  // = 128
            p += 1
        } while (read_next)
        
        return result
    }
    
    static let setup: () = {
        dumpAllExportedSymbol()
    }()

    
    public class func start(key: String) {
        FKSwiftSectionFunction.default.start(key: key)
    }
    
    public func start(key: String) {
        typealias classFunc = @convention(thin) () -> Void
        var keySymbols : [UnsafeMutableRawPointer?] = []
        FKSwiftSectionFunction.workQueue.sync {
            guard let organizedKeySymbols = organizedSymbols[key] else {
                exportedSymbols.forEach { (fullKey, symbol) in
                    if fullKey.hasPrefix(fullNamespace + key + ".") || fullKey == fullNamespace + key {
                        keySymbols.append(symbol)
                        exportedSymbols.removeValue(forKey: fullKey)
                    }
                }
                organizedSymbols[key] = keySymbols
                return
            }
            keySymbols = organizedKeySymbols
        }
        keySymbols.forEach { (symbol) in
            let f = unsafeBitCast(symbol, to: classFunc.self)
            f()
        }
    }

    private static let linkeditName = SEG_LINKEDIT.utf8CString
    func getExportedSymbols(image:UnsafePointer<mach_header>!, slide: Int) -> [String : UnsafeMutableRawPointer?] {
        var linkeditCmd: UnsafeMutablePointer<segment_command_64>!
        var dynamicLoadInfoCmd: UnsafeMutablePointer<dyld_info_command>!
        
        var curCmd = UnsafeMutableRawPointer(mutating: image).advanced(by: MemoryLayout<mach_header_64>.size).assumingMemoryBound(to: segment_command_64.self)
        
        for _ in 0..<image.pointee.ncmds {
            if curCmd.pointee.cmd == LC_SEGMENT_64 {
                
                if  curCmd.pointee.segname.0 == FKSwiftSectionFunction.linkeditName[0] &&
                        curCmd.pointee.segname.1 == FKSwiftSectionFunction.linkeditName[1] &&
                        curCmd.pointee.segname.2 == FKSwiftSectionFunction.linkeditName[2] &&
                        curCmd.pointee.segname.3 == FKSwiftSectionFunction.linkeditName[3] &&
                        curCmd.pointee.segname.4 == FKSwiftSectionFunction.linkeditName[4] &&
                        curCmd.pointee.segname.5 == FKSwiftSectionFunction.linkeditName[5] &&
                        curCmd.pointee.segname.6 == FKSwiftSectionFunction.linkeditName[6] &&
                        curCmd.pointee.segname.7 == FKSwiftSectionFunction.linkeditName[7] &&
                        curCmd.pointee.segname.8 == FKSwiftSectionFunction.linkeditName[8] &&
                        curCmd.pointee.segname.9 == FKSwiftSectionFunction.linkeditName[9] {
                    linkeditCmd = curCmd
                }
            } else if curCmd.pointee.cmd == LC_DYLD_INFO_ONLY || curCmd.pointee.cmd == LC_DYLD_INFO {
                dynamicLoadInfoCmd = curCmd.withMemoryRebound(to: dyld_info_command.self, capacity: 1, { $0 })
            }
            
            let curCmdSize = Int(curCmd.pointee.cmdsize)
            let _curCmd = curCmd.withMemoryRebound(to: Int8.self, capacity: 1, { $0 }).advanced(by: curCmdSize)
            curCmd = _curCmd.withMemoryRebound(to: segment_command_64.self, capacity: 1, { $0 })
        }
        
        if linkeditCmd == nil || dynamicLoadInfoCmd == nil {
            return [String : UnsafeMutableRawPointer?]()
        }
        
        let linkeditBase = slide + Int(linkeditCmd.pointee.vmaddr) - Int(linkeditCmd.pointee.fileoff)
        guard let exportedInfo = UnsafeMutableRawPointer(bitPattern: linkeditBase + Int(dynamicLoadInfoCmd.pointee.export_off))?.assumingMemoryBound(to: UInt8.self) else {
            return [String : UnsafeMutableRawPointer?]()
        }
        let exportedInfoSize = Int(dynamicLoadInfoCmd.pointee.export_size)
        
        var symbols = [String : UnsafeMutableRawPointer?]()
        trieWalk(image: image, start: exportedInfo, loc: exportedInfo, end: exportedInfo + exportedInfoSize, currentSymbol: "", symbols: &symbols)
        
        return symbols
    }
    

    
    private func trieWalk(image:UnsafePointer<mach_header>!,
                                 start:UnsafeMutablePointer<UInt8>,
                                 loc:UnsafeMutablePointer<UInt8>,
                                 end:UnsafeMutablePointer<UInt8>,
                                 currentSymbol: String,
                                 symbols: inout [String : UnsafeMutableRawPointer?]) {
        var p = loc
        if p <= end {
            var terminalSize = UInt64(p.pointee)
            if terminalSize > 127 {
                p -= 1
                terminalSize = FKSwiftSectionFunction.readUleb128(p: &p, end: end)
            }
            if terminalSize != 0 {
                guard currentSymbol.hasPrefix(fullNamespace) else {
                    return
                }

                let returnSwiftSymbolAddress = { () -> UnsafeMutableRawPointer in
                    let machO = image.withMemoryRebound(to: Int8.self, capacity: 1, { $0 })
                    let swiftSymbolAddress = machO.advanced(by: Int(FKSwiftSectionFunction.readUleb128(p: &p, end: end)))
                    return UnsafeMutableRawPointer(mutating: swiftSymbolAddress)
                }
                
                p += 1
                let flags = FKSwiftSectionFunction.readUleb128(p: &p, end: end)
                switch flags & UInt64(EXPORT_SYMBOL_FLAGS_KIND_MASK) {
                case UInt64(EXPORT_SYMBOL_FLAGS_KIND_REGULAR):
                    symbols[currentSymbol] = returnSwiftSymbolAddress()
                case UInt64(EXPORT_SYMBOL_FLAGS_KIND_THREAD_LOCAL):
                    if (flags & UInt64(EXPORT_SYMBOL_FLAGS_STUB_AND_RESOLVER) != 0) {
                    }
                case UInt64(EXPORT_SYMBOL_FLAGS_KIND_ABSOLUTE):
                    if (flags & UInt64(EXPORT_SYMBOL_FLAGS_STUB_AND_RESOLVER) != 0) {
                    }
                    symbols[currentSymbol] = UnsafeMutableRawPointer(bitPattern: UInt(FKSwiftSectionFunction.readUleb128(p: &p, end: end)))
                default:
                    break
                }
            }
            
            let child = loc.advanced(by: Int(terminalSize + 1))
            let childCount = child.pointee
            p = child + 1
            for _ in 0 ..< childCount {
                let nodeLabel = String(cString: p.withMemoryRebound(to: CChar.self, capacity: 1, { $0 }), encoding: .utf8)
                // advance to the end of node's label
                while p.pointee != 0 {
                    p += 1
                }
                
                // so advance to the child's node
                p += 1
                let nodeOffset = Int(FKSwiftSectionFunction.readUleb128(p: &p, end: end))
                if nodeOffset != 0, let nodeLabel = nodeLabel {
                    let symbol = currentSymbol + nodeLabel
//                    print(currentSymbol + " + " + nodeLabel)
                    // find common parent node first then get all _FKSwiftSectionFunction: node.
                    if symbol.lengthOfBytes(using: .utf8) > 0 && (symbol.hasPrefix(fullNamespace) || fullNamespace.hasPrefix(symbol)) {
                        trieWalk(image: image, start: start, loc: start.advanced(by: nodeOffset), end: end, currentSymbol: symbol, symbols: &symbols)
                    }
                }
            }
        }
    }
}

extension FKSectionFunction {
    @objc func executeSwiftFunctions(forKey: String) {
        FKSwiftSectionFunction.start(key: forKey)
    }
}
