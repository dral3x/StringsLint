//
//  StringsParser.swift
//  StringsLintFramework
//
//  Created by Alessandro "Sandro" Calzavara on 11/09/2018.
//

import Foundation

public struct StringsParser: LocalizableParser {

    public static var identifier: String {
        return "strings_parser"
    }
    
    public var supportedFileExtentions: [String] {
        return [ "strings" ]
    }
    
    public init() {
    }
    
    public init(configuration: Any) throws {
        // Parser does not support any configuration
        self.init()
    }
    
    public func support(file: File) -> Bool {
        return file.name.hasSuffix(".strings")
    }
    
    public func parse(file: File) throws -> [LocalizedString] {
        
        let tableName = file.name.bridge().deletingPathExtension
        let locale = Locale(url: file.url)
        
        var strings = [LocalizedString]()
                
        for (index, line) in file.lines.enumerated() {
            if let key = line.extractLocalizedKey() {
                strings.append(LocalizedString(key: key, table: tableName, locale: locale, location: Location(file: file, line: index+1)))
            }
        }

        return strings
    }
}

extension String {
    
    private func matchFirst(regex: String) -> String? {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            if let result = regex.firstMatch(in: self, range: NSRange(self.startIndex..., in: self)) {
                return String(self[Range(result.range(at: 1), in: self)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
        }
        return nil
    }
    
    fileprivate func extractLocalizedKey() -> String? {
        return self.matchFirst(regex: "^\"(?<key>.*)\" = \"(.*)\";$")
    }
    
    fileprivate func extractTableName() -> String? {
        return self.matchFirst(regex: "asd")
    }
}
