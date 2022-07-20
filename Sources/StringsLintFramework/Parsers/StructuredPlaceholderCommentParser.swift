//
//  StructuredPlaceholderCommentParser.swift
//  
//
//  Created by Mark Hall on 2022-07-19.
//

import Foundation

public struct StructuredPlaceholderCommentParser: LocalizableParser {

    enum StructuredPlaceholderCommentParserError: Error {
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

    //TODO: (Mark Hall, July 18) only need to support the english file
    public func support(file: File) -> Bool {
        return file.name.hasSuffix(".strings")
    }

    public func parse(file: File) throws -> [LocalizedString] {

        let tableName = file.name.bridge().deletingPathExtension
        let locale = Locale(url: file.url)

        var strings = [LocalizedString]()
        guard file.content.contains("//--START CONTENT--") else {
            throw StructuredPlaceholderCommentParserError.missingHeaderSeparatorComment
        }
        guard let rawStrings = file.content.components(separatedBy: "//--START CONTENT--").last?.components(separatedBy: ";") else {
            return [] //should never get here given the previous guard
        }

        let allLines = file.lines.enumerated()

        for rawString in rawStrings {
            if let key = rawString.extractLocalizedKey() {
                let commentForLocalizedString = rawString.extractMultiLineComment()
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
        //TODO: (Mark Hall, July 19) only checking for %@ and %d right now, not sure that is everything we should be looking for
        self.matchAll(regex: "%(\\d\\$)?[@d]") ?? []
    }

    func extractLocalizedKey() -> String? {
        return self.matchFirst(regex: "\"(?<key>.*)\" = \"(.*)\"")
    }

    /// Matches comments in the format
    /// /*
    /// {
    ///    "test": "testValue"
    /// }
    /// */
    /// - Returns: The entire comment
    func extractMultiLineComment() -> String? {
        return self.matchFirstSafe(regex: "\\/\\*(.|\n)*\\*\\/")?
            .trimmingCharacters(in: CharacterSet(charactersIn: "/**/"))
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
