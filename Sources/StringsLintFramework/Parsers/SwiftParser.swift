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
    let customRegex: CustomRegex?
    let ignoreThisPattern: String

    public var supportedFileExtentions: [String] {
        return [ "swift" ]
    }
    
    public init() {
        let config = SwiftParserConfiguration()
        self.init(macros: config.macros, customRegex: config.customRegex)
    }
    
    public init(configuration: Any) throws {
        var config = SwiftParserConfiguration()
        do {
            try config.apply(defaultDictionaryValue(configuration, for: SwiftParser.self.identifier))
        } catch {}
        
        self.init(macros: config.macros, customRegex: config.customRegex)
    }
    
    public init(macros: [String], customRegex: CustomRegex? = nil) {
        self.uiKitPattern = "(\(macros.joined(separator: "|")))\\(\"([^\"]+)\", (tableName: \"([^\"]+)\", )?(comment: \"([^\"]*)\")\\)"
        self.swiftUIExplicitPattern = "Text\\((LocalizedStringKey\\()?\"([^\"]+)\"\\)?, tableName: \"([^\"]+)\"(, comment: \"([^\"]*)\")?\\)"
        self.swiftUIImplicitPattern = "(Text|Button|LocalizedStringKey)\\(\"([^\"]+)\"\\)"
        self.ignoreThisPattern = "//stringslint:ignore"
        self.customRegex = customRegex
    }

    public func support(file: File) -> Bool {
        return file.name.hasSuffix(".swift")
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

        // Swift UI - explicit

        do {
            let regex = try NSRegularExpression(pattern: self.swiftUIExplicitPattern)
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

                strings.append(LocalizedString(key: key, table: table, locale: .none, location: location))

            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
        }

        // Swift UI - implicit
        if strings.isEmpty {
            do {
                let regex = try NSRegularExpression(pattern: self.swiftUIImplicitPattern)
                let results = regex.matches(in: text, options: [ .reportCompletion ], range: NSRange(text.startIndex..., in: text))
                for result in results {

                    var key = ""
                    if result.numberOfRanges > 2 {
                        key = String(text[Range(result.range(at: 2), in: text)!])
                    }

                    strings.append(LocalizedString(key: key, table: "Localizable", locale: .none, location: location))

                }
            } catch let error {
                print("invalid regex: \(error.localizedDescription)")
            }
        }

        if let customRegex = customRegex {
            do {
                let regex = try NSRegularExpression(pattern: customRegex.pattern)
                let results = regex.matches(in: text, options: [ .reportCompletion ], range: NSRange(text.startIndex..., in: text))
                
                for result in results {

                    var key = ""
                    if result.numberOfRanges > customRegex.matchIndex {
                        key = String(text[Range(result.range(at: customRegex.matchIndex), in: text)!])
                    }

                    strings.append(LocalizedString(key: key, table: "Localizable", locale: .none, location: location))

                }
            } catch let error {
                print("invalid regex: \(error.localizedDescription)")
            }
        }

        return strings
    }
    
}
