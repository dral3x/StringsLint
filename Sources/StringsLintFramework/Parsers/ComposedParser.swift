//
//  ComposedParser.swift
//  StringsLintFramework
//
//  Created by Alessandro "Sandro" Calzavara on 04/11/2018.
//

import Foundation

public struct ComposedParser: LocalizableParser {
    public static var identifier: String {
        return "composed_parser"
    }
    
    public var supportedFileExtentions: [String] {
        return self.parsers.flatMap { $0.supportedFileExtentions }
    }
    
    let parsers: [LocalizableParser]
    
    public init(parsers: [LocalizableParser]) {
        self.parsers = parsers
    }
    
    public init() {
        // Parser does not support plain init
        fatalError("Parser does not support plain init")
    }
    
    public init(configuration: Any) throws {
        // Parser does not support any configuration
        fatalError("Parser does not support configuration")
    }
    
    public func support(file: File) -> Bool {
        return self.parsers.compactMap { $0.support(file: file) }.contains(true)
    }
    
    public func parse(file: File) throws -> [LocalizedString] {
        
        var results = [LocalizedString]()
        
        for parser in self.parsers {
            if parser.support(file: file) {
                results += try parser.parse(file: file)
            }
        }
        
        return results
    }
}
