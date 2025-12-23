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

    let foundationPattern: String
    let stringPattern: String
    let swiftUIImplicitPattern: String
    let swiftUIImplicitEnabled: Bool
    let swiftUIExplicitPattern: String
    let customRegex: CustomRegex?
    let ignoreThisPattern: String

    public var supportedFileExtentions: [String] {
        return ["swift"]
    }

    public init() {
        let config = SwiftParserConfiguration()
        self.init(macros: config.macros, customRegex: config.customRegex, swiftUIImplicitEnabled: config.swiftUIImplicitEnabled)
    }

    public init(configuration: Any) throws {
        var config = SwiftParserConfiguration()
        do {
            try config.apply(defaultDictionaryValue(configuration, for: SwiftParser.self.identifier))
        } catch {}

        self.init(macros: config.macros, customRegex: config.customRegex, swiftUIImplicitEnabled: config.swiftUIImplicitEnabled)
    }

    private static var implicitPatternPrefix: String {
        let tags = [
            "Text",
            "Button",
            "TextField",
            "Toggle",
            "LocalizedStringKey",
            ".accessibilityLabel",
            ".navigationTitle",
        ]
        return tags.joined(separator: "|")
    }

    public init(macros: [String], customRegex: CustomRegex?, swiftUIImplicitEnabled: Bool) {
        self.foundationPattern = "(\(macros.joined(separator: "|")))\\(\"(?<key>[^\"]+)\", (tableName: \"(?<table>[^\"]+)\", )?(value: \"(?<value>[^\"]+)\", )?(comment: \"([^\"]*)\")\\)"
        self.stringPattern = "String\\(localized: \"(?<key>[^\"]+)\"(, defaultValue: \"(?<value>[^\"]+)\")?(, table: \"(?<table>[^\"]+)\")?(, comment: \"([^\"]*)\")?\\)"
        self.swiftUIExplicitPattern = "Text\\((LocalizedStringKey\\()?\"([^\"]+)\"\\)?, tableName: \"([^\"]+)\"(, comment: \"([^\"]*)\")?\\)"
        self.swiftUIImplicitPattern = "(\(SwiftParser.implicitPatternPrefix))\\(\"([^\"]+)\"[^)]*\\)"
        self.ignoreThisPattern = "//\\s?stringslint:ignore"
        self.customRegex = customRegex
        self.swiftUIImplicitEnabled = swiftUIImplicitEnabled
    }

    public func support(file: File) -> Bool {
        return file.name.hasSuffix(".swift")
    }

    public func parse(file: File) throws -> [LocalizedString] {
        var strings = [LocalizedString]()

        for (index, line) in file.lines.enumerated() {
            if self.hasIgnoreThisLineComment(line) { continue }
            let normalizedLine = normalizeKeysWithInterpolation(line)
            let results = self.extractLocalizedStrings(from: normalizedLine, location: Location(file: file, line: index + 1))
            strings += results
        }

        return strings
    }

    private func hasIgnoreThisLineComment(_ text: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: self.ignoreThisPattern)
            let results = regex.matches(in: text, options: [.reportCompletion], range: NSRange(text.startIndex..., in: text))
            return !results.isEmpty
        } catch {
            print("invalid regex: \(error.localizedDescription)")
            return false
        }
    }

    private func normalizeKeysWithInterpolation(_ input: String) -> String {
        var result = input
        var searchStart = result.startIndex

        while let startRange = result.range(of: "\\(", range: searchStart ..< result.endIndex) {
            var parenCount = 1
            var currentIndex = result.index(after: startRange.upperBound)

            while currentIndex < result.endIndex && parenCount > 0 {
                let char = result[currentIndex]
                if char == "(" {
                    parenCount += 1
                } else if char == ")" {
                    parenCount -= 1
                }
                currentIndex = result.index(after: currentIndex)
            }

            if parenCount == 0 {
                let fullRange = startRange.lowerBound ..< currentIndex
                result.replaceSubrange(fullRange, with: "%@")
                searchStart = startRange.lowerBound
                searchStart = result.index(searchStart, offsetBy: 2) // Move past %@
            } else {
                break
            }
        }

        return result
    }

    private func extractLocalizedStrings(from text: String, location: Location) -> [LocalizedString] {
        var strings = [LocalizedString]()

        // Foundation
        do {
            let regex = try NSRegularExpression(pattern: self.foundationPattern)
            let results = regex.matches(in: text, options: [.reportCompletion], range: NSRange(text.startIndex..., in: text))
            for result in results {
                let keyRange = result.range(withName: "key")
                let tableRange = result.range(withName: "table")
                let valueRange = result.range(withName: "value")

                var key = ""
                if keyRange.location != NSNotFound {
                    key = String(text[Range(keyRange, in: text)!])
                }

                var table = "Localizable"
                if tableRange.location != NSNotFound {
                    table = String(text[Range(tableRange, in: text)!])
                }

                var value: String? = nil
                if valueRange.location != NSNotFound {
                    value = String(text[Range(valueRange, in: text)!])
                }

                strings.append(LocalizedString(key: key, table: table, value: value, locale: .none, location: location))
            }
        } catch {
            print("invalid regex: \(error.localizedDescription)")
        }

        do {
            let regex = try NSRegularExpression(pattern: self.stringPattern)
            let results = regex.matches(in: text, options: [.reportCompletion], range: NSRange(text.startIndex..., in: text))
            for result in results {
                let keyRange = result.range(withName: "key")
                let tableRange = result.range(withName: "table")
                let valueRange = result.range(withName: "value")

                var key = ""
                if keyRange.location != NSNotFound {
                    key = String(text[Range(keyRange, in: text)!])
                }

                var table = "Localizable"
                if tableRange.location != NSNotFound {
                    table = String(text[Range(tableRange, in: text)!])
                }

                var value: String? = nil
                if valueRange.location != NSNotFound {
                    value = String(text[Range(valueRange, in: text)!])
                }

                strings.append(LocalizedString(key: key, table: table, value: value, locale: .none, location: location))
            }
        } catch {
            print("invalid regex: \(error.localizedDescription)")
        }

        // Swift UI - explicit

        do {
            let regex = try NSRegularExpression(pattern: self.swiftUIExplicitPattern)
            let results = regex.matches(in: text, options: [.reportCompletion], range: NSRange(text.startIndex..., in: text))
            for result in results {
                var key = ""
                if result.numberOfRanges > 2 {
                    key = String(text[Range(result.range(at: 2), in: text)!])
                }

                var table = "Localizable"
                if result.numberOfRanges > 3, result.range(at: 3).location != NSNotFound {
                    table = String(text[Range(result.range(at: 3), in: text)!])
                }

                strings.append(LocalizedString(key: key, table: table, value: nil, locale: .none, location: location))
            }
        } catch {
            print("invalid regex: \(error.localizedDescription)")
        }

        // Swift UI - implicit
        if strings.isEmpty && self.swiftUIImplicitEnabled {
            do {
                let regex = try NSRegularExpression(pattern: self.swiftUIImplicitPattern)
                let results = regex.matches(in: text, options: [.reportCompletion], range: NSRange(text.startIndex..., in: text))
                for result in results {
                    var key = ""
                    if result.numberOfRanges > 2 {
                        key = String(text[Range(result.range(at: 2), in: text)!])
                    }

                    strings.append(LocalizedString(key: key, table: "Localizable", value: nil, locale: .none, location: location))
                }
            } catch {
                print("invalid regex: \(error.localizedDescription)")
            }
        }

        if let customRegex = customRegex {
            do {
                let regex = try NSRegularExpression(pattern: customRegex.pattern)
                let results = regex.matches(in: text, options: [.reportCompletion], range: NSRange(text.startIndex..., in: text))

                for result in results {
                    var key = ""
                    if result.numberOfRanges > customRegex.matchIndex {
                        key = String(text[Range(result.range(at: customRegex.matchIndex), in: text)!])
                    }

                    strings.append(LocalizedString(key: key, table: "Localizable", value: nil, locale: .none, location: location))
                }
            } catch {
                print("invalid regex: \(error.localizedDescription)")
            }
        }

        return strings
    }
}
