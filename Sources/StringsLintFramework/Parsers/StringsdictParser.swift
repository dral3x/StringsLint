//
//  StringsdictParser.swift
//  StringsLintFramework
//
//  Created by Alessandro "Sandro" Calzavara on 27/03/2019.
//

import Foundation

public struct StringsdictParser: LocalizableParser {
    
    public static var identifier: String {
        return "stringsdict_parser"
    }
    
    public var supportedFileExtentions: [String] {
        return [ "stringsdict" ]
    }
    
    public init() {
    }
    
    public init(configuration: Any) throws {
        // Parser does not support any configuration
        self.init()
    }
    
    public func support(file: File) -> Bool {
        return file.name.hasSuffix(".stringsdict")
    }
    
    public func parse(file: File) throws -> [LocalizedString] {
        
        let tableName = file.name.bridge().deletingPathExtension
        let locale = Locale(url: file.url)
        
        var strings = [LocalizedString]()
        
        var propertyListForamt: PropertyListSerialization.PropertyListFormat = .xml
        let data = try PropertyListSerialization.propertyList(from: file.content.data(using: .utf8)!, options: [.mutableContainersAndLeaves], format: &propertyListForamt) as! [String: AnyObject]
        
        for key in data.keys.sorted() {
            if let index = file.lines.firstIndex(where: { (line) -> Bool in
                line.contains(key)
            }) {
                strings.append(LocalizedString(key: key, table: tableName, value: nil, locale: locale, location: Location(file: file, line: index+1)))
            }
        }
        
        return strings
    }
    
}
