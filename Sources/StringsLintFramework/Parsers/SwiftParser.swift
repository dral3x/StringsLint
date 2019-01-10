//
//  SwiftParser.swift
//  StringsLintFramework
//
//  Created by Alessandro "Sandro" Calzavara on 11/09/2018.
//

import Foundation

public struct SwiftParser: LocalizableParser {

    public static var identifier: String {
        return "swift_parser"
    }
    
    let pattern: String
    
    public var supportedFileExtentions: [String] {
        return [ "swift" ]
    }
    
    public init() {
        let config = SwiftParserConfiguration()
        self.init(macros: config.macros)
    }
    
    public init(configuration: Any) throws {
        var config = SwiftParserConfiguration()
        do {
            try config.apply(defaultDictionaryValue(configuration, for: SwiftParser.self.identifier))
        } catch {}
        
        self.init(macros: config.macros)
    }
    
    public init(macros: [String]) {
        self.pattern = "(\(macros.joined(separator: "|")))\\(\"([^\"]+)\", (tableName: \"([^\"]+)\", )?(comment: \"([^\"]*)\")\\)"
    }
    
    public func support(file: File) -> Bool {
        return file.name.hasSuffix(".swift")
    }
    
    public func parse(file: File) throws -> [LocalizedString] {
        var strings = [LocalizedString]()
        
        for (index, line) in file.lines.enumerated() {
            let results = self.extractLocalizedStrings(from: line, location: Location(file: file, line: index+1))
            strings += results
        }
        
        return strings
    }
    
    private func extractLocalizedStrings(from text: String, location: Location) -> [LocalizedString] {
        
        var strings = [LocalizedString]()
        
        do {
            let regex = try NSRegularExpression(pattern: self.pattern)
            let results = regex.matches(in: text, options: [ .reportCompletion ], range: NSRange(text.startIndex..., in: text))
            for result in results {
                
                var key = ""
                if result.numberOfRanges > 2 {
                    key = String(text[Range(result.range(at: 2), in: text)!])
                }
                
                var table = "Localizable"
                if result.numberOfRanges > 4, result.range(at: 4).location != NSNotFound {
                    table = String(text[Range(result.range(at: 4), in: text)!])
                }
                
                strings.append(LocalizedString(key: key, table: table, locale: .none, location: location))
                
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
        }
        
        return strings
    }
    
}
