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
            if let key = line.localizedKey {

                let previousLine = (index > 0) ? file.lines[index - 1] : ""
                let commentForLocalizedString = previousLine.comment

                strings.append(LocalizedString(key: key, table: tableName, locale: locale, location: Location(file: file, line: index+1), comment: commentForLocalizedString))
            }
        }

        return strings
    }
}
