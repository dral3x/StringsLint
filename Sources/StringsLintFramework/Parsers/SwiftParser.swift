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
    
    let uiKitPattern: String
    let swiftUIImplicitPattern: String
    let swiftUIExplicitPattern: String
    
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
        self.uiKitPattern = "(\(macros.joined(separator: "|")))\\(\"([^\"]+)\"(, tableName: \"([^\"]+)\")?(, comment: \"([^\"]*)\")?\\)"
        self.swiftUIImplicitPattern = "Text\\(\"([^\"]+)\"\\)"
        self.swiftUIExplicitPattern = "Text\\(LocalizedStringKey\\(\"([^\"]+)\"\\)(, tableName: \"([^\"]+)\")?.*\\)"
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
        
        // UIKit
        
        do {
            let regex = try NSRegularExpression(pattern: self.uiKitPattern)
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
        
        // Swift UI - implicit
        
        do {
            let regex = try NSRegularExpression(pattern: self.swiftUIImplicitPattern)
            let results = regex.matches(in: text, options: [ .reportCompletion ], range: NSRange(text.startIndex..., in: text))
            for result in results {
                
                var key = ""
                if result.numberOfRanges > 1 {
                    key = String(text[Range(result.range(at: 1), in: text)!])
                }
                
                strings.append(LocalizedString(key: key, table: "Localizable", locale: .none, location: location))
                
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
        }
        
        // Swift UI - explicit
        
        do {
            let regex = try NSRegularExpression(pattern: self.swiftUIExplicitPattern)
            let results = regex.matches(in: text, options: [ .reportCompletion ], range: NSRange(text.startIndex..., in: text))
            for result in results {
                
                var key = ""
                if result.numberOfRanges > 1 {
                    key = String(text[Range(result.range(at: 1), in: text)!])
                }
                
                var table = "Localizable"
                if result.numberOfRanges > 3, result.range(at: 3).location != NSNotFound {
                    table = String(text[Range(result.range(at: 3), in: text)!])
                }
                
                strings.append(LocalizedString(key: key, table: table, locale: .none, location: location))
                
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
        }
        
        return strings
    }
    
}
