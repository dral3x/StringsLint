//
//  StringsJSONCommentParser.swift
//  
//
//  Created by Mark Hall on 2022-07-19.
//

import Foundation

public struct StringsJSONCommentParser: LocalizableParser {

    public static var identifier: String {
        return "structured_placeholder_comment_parser"
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
        let rawStrings = removeHeaderComment(from: file.content).components(separatedBy: ";")

        let allLines = file.lines.enumerated()

        for rawString in rawStrings {
            if let key = rawString.localizedKey {
                let commentForLocalizedString = rawString.multiLineComment?
                    .trimmingCharacters(in: CharacterSet(charactersIn: "/**/"))
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                let lineNumber = (allLines.first(where: { $0.element.localizedKey == key })?.offset ?? -1) + 1
                strings.append(LocalizedString(key: key,
                                               table: tableName,
                                               locale: locale,
                                               location: Location(file: file, line: lineNumber),
                                               placeholders: rawString.localizedStringPlaceholders,
                                               comment: commentForLocalizedString))
            }
        }

        return strings
    }

    private func removeHeaderComment(from content: String) -> String {
        var lastHeaderIndex = 0
        var lastChar: Character?
        for c in content {
            if let lastChar = lastChar,
               lastChar == "*",
               c == "/" { break }
            lastChar = c
            lastHeaderIndex += 1
        }

        let suffixLenght = content.count - lastHeaderIndex - 1
        return String(content.suffix(suffixLenght))
    }

}

private extension String {
    var localizedStringPlaceholders: [String] {
        // %d/%i/%o/%u/%x with their optional length modifiers like in "%lld"
        let patternInt = "(?:h|hh|l|ll|q|z|t|j)?([dioux])"
        // valid flags for float
        let patternFloat = "[aefg]"
        // like in "%3$" to make positional specifiers
        let position = "(\\d+\\$)?"
        // precision like in "%1.2f"
        let precision = "[-+# 0]?\\d?(?:\\.\\d)?"
        return self.matchAll(regex: "(?:^|(?<!%)(?:%%)*)%\(position)\(precision)(@|\(patternInt)|\(patternFloat)|[csp])") ?? []
    }
}
