//
//  ObjcParser.swift
//  StringsLintFramework
//
//  Created by Alessandro "Sandro" Calzavara on 11/09/2018.
//

import Foundation

public struct ObjcParser: LocalizableParser {
    
    public static var identifier: String {
        return "objc_parser"
    }
    
    let implicitPattern: String
    let explicitPattern: String
    let ignoreThisPattern: String

    public var supportedFileExtentions: [String] {
        return [ "m" ]
    }
    
    public init() {
        let config = ObjcParserConfiguration()
        self.init(implicitMacros: config.implicitMacros, explicitMacros: config.explicitMacros)
    }
    
    public init(configuration: Any) throws {
        var config = ObjcParserConfiguration()
        do {
            try config.apply(defaultDictionaryValue(configuration, for: ObjcParser.self.identifier))
        } catch {}
        
        self.init(implicitMacros: config.implicitMacros, explicitMacros: config.explicitMacros)
    }
    
    public init(implicitMacros: [String], explicitMacros: [String]) {
        self.implicitPattern = "(\(implicitMacros.joined(separator: "|")))\\(@\"([^\"]+)\", (@\"([^\"]*)\"|nil)\\)"
        self.explicitPattern = "(\(explicitMacros.joined(separator: "|")))\\(@\"([^\"]+)\", @\"([^\"]*)\", (@\"([^\"]*)\"|nil)\\)"
        self.ignoreThisPattern = "//stringslint:ignore"
    }
    
    public func support(file: File) -> Bool {
        return file.name.hasSuffix(".m")
    }
    
    public func parse(file: File) throws -> [LocalizedString] {
        var strings = [LocalizedString]()
        
        for (index, line) in file.lines.enumerated() {
            if self.hasIgnoreThisLineComment(line) { continue }
            let results = self.extractLocalizedStrings(from: line, location: Location(file: file, line: index+1))
            strings += results
        }
        
        return strings
    }
    
    private func hasIgnoreThisLineComment(_ text: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: self.ignoreThisPattern)
            let results = regex.matches(in: text, options: [ .reportCompletion ], range: NSRange(text.startIndex..., in: text))
            return !results.isEmpty
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return false
        }
    }
    
    private func extractLocalizedStrings(from text: String, location: Location) -> [LocalizedString] {
        
        var strings = [LocalizedString]()
        
        do {
            let regex = try NSRegularExpression(pattern: self.explicitPattern)
            let results = regex.matches(in: text, options: [ .reportCompletion ], range: NSRange(text.startIndex..., in: text))
            for result in results {
                
                var key = ""
                if result.numberOfRanges > 2 {
                    key = String(text[Range(result.range(at: 2), in: text)!])
                }
                
                var table = "Localizable"
                if result.numberOfRanges > 3, result.range(at: 3).location != NSNotFound {
                    table = String(text[Range(result.range(at: 3), in: text)!])
                }
                
                strings.append(LocalizedString(key: key, table: table, value: nil, locale: .none, location: location))

            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
        }
        
        do {
            let regex = try NSRegularExpression(pattern: self.implicitPattern)
            let results = regex.matches(in: text, options: [ .reportCompletion ], range: NSRange(text.startIndex..., in: text))
            for result in results {
                
                var key = ""
                if result.numberOfRanges > 2 {
                    key = String(text[Range(result.range(at: 2), in: text)!])
                }
                
                strings.append(LocalizedString(key: key, table: "Localizable", value: nil, locale: .none, location: location))
                
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
        }
        
        return strings
    }
}
