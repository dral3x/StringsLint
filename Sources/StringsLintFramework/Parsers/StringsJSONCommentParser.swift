//
//  StringsJSONCommentParser.swift
//  
//
//  Created by Mark Hall on 2022-07-19.
//

import Foundation

public struct StringsJSONCommentParser: LocalizableParser {

    enum StringsJSONCommentParserError: Error {
        case missingHeaderSeparatorComment
    }

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
        guard file.content.contains("//--START CONTENT--") else {
            throw StringsJSONCommentParserError.missingHeaderSeparatorComment
        }
        guard let rawStrings = file.content.components(separatedBy: "//--START CONTENT--").last?.components(separatedBy: ";") else {
            return [] //should never get here given the previous guard
        }

        let allLines = file.lines.enumerated()

        for rawString in rawStrings {
            if let key = rawString.localizedKey {
                let commentForLocalizedString = rawString.comment?
                    .trimmingCharacters(in: CharacterSet(charactersIn: "/**/"))
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                let lineNumber = (allLines.first(where: { $0.element.contains(key) })?.offset ?? -1) + 1
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
