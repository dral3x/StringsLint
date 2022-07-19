//
//  File.swift
//  
//
//  Created by Mark Hall on 2022-07-19.
//

import Foundation

public struct StructuredPlaceholderCommentParser: LocalizableParser {

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

        let rawStrings = file.content.components(separatedBy: ";")

        for (index, rawString) in rawStrings.enumerated() {
            if let key = rawString.extractLocalizedKey() {
                let commentForLocalizedString = rawString.extractMultiLineComment()

                strings.append(LocalizedString(key: key,
                                               table: tableName,
                                               locale: locale,
                                               location: Location(file: file, line: index+1), //TODO: (Mark Hall, July 19) line is wrong
                                               placeholders: rawString.localizedStringPlaceholders,
                                               comment: commentForLocalizedString))
            }
        }

        return strings
    }
}

private extension String {
    var localizedStringPlaceholders: [String] {
        //TODO: (Mark Hall, July 19) only checking for %@ and %d rn, not sure that is eveerything we should be looking for
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
