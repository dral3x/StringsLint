//
//  XibParser.swift
//  StringsLintFramework
//
//  Created by Alessandro "Sandro" Calzavara on 11/09/2018.
//

import Foundation

public struct XibParser: LocalizableParser {
    
    public static var identifier: String {
        return "xib_parser"
    }
    
    let pattern: String
    
    public var supportedFileExtentions: [String] {
        return [ "xib", "storyboard" ]
    }
    
    public init() {
        self.init(keyPaths: [])
    }
    
    public init(configuration: Any) throws {
        var config = XibParserConfiguration()
        do {
            try config.apply(defaultDictionaryValue(configuration, for: XibParser.self.identifier))
        } catch {}
        
        self.init(keyPaths: config.keyPaths)
    }
    
    public init(keyPaths: [String]) {
        self.pattern = "<userDefinedRuntimeAttribute type=\"string\" keyPath=\"(\(keyPaths.joined(separator: "|")))\" value=\"(.*?)\"/>"
    }
    
    public func support(file: File) -> Bool {
        return file.name.hasSuffix(".xib") || file.name.hasSuffix(".storyboard")
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
                
                strings.append(LocalizedString(key: key, table: "Localizable", locale: .none, location: location))
                
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
        }
        
        return strings
    }
}
