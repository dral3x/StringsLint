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
                guard let value = data[key] as? [String: Any],
                      let item = try? StringDict.PluralItem(key: key, value: value) else {
                    continue
                }

              //if the string doesn't actually contain the placeholder, we don't want to force the comment to have a `placeholders` value
              let doesStringContainPlaceholder = item.strings.contains { $0.contains("%\(item.format.formatValueKey)") }
              let validPlaceholders = doesStringContainPlaceholder ? [item.format.formatValueKey] : []
                strings.append(LocalizedString(key: key,
                                               table: tableName,
                                               locale: locale,
                                               location: Location(file: file, line: index+1),
                                               placeholders: validPlaceholders,
                                               comment: item.formattedComment))
            }
        }
        
        return strings
    }
    
}
