//
//  XCStringsParser.swift
//  StringsLintFramework
//

import Foundation

public struct XCStringsParser: LocalizableParser {

    public static var identifier: String {
        return "xcstrings_parser"
    }

    public var supportedFileExtentions: [String] {
        return [ "xcstrings" ]
    }

    public init() {
    }

    public init(configuration: Any) throws {
        // Parser does not support any configuration
        self.init()
    }

    public func support(file: File) -> Bool {
        return file.name.hasSuffix(".xcstrings")
    }

    public func parse(file: File) throws -> [LocalizedString] {

        let tableName = file.name.bridge().deletingPathExtension

        let data = Data(file.content.utf8)
        let catalog = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let entries = catalog?["strings"] as? [String: Any] ?? [:]
        let sourceLanguage = catalog?["sourceLanguage"] as? String

        let lineNumbers = self.lineNumbers(in: file, for: entries)

        var strings = [LocalizedString]()

        let keys = entries.keys.sorted()

        for key in keys {
            let entry = entries[key] as? [String: Any] ?? [:]

            if entry["shouldTranslate"] as? Bool == false {
                continue
            }

            let comment = entry["comment"] as? String

            let line = lineNumbers[key]
            let location = Location(file: file, line: line)

            let translatedLocales = self.translatedLocales(of: entry, sourceLanguage: sourceLanguage)

            for languageCode in translatedLocales {
                let locale = Locale(languageCode: languageCode)

                let string = LocalizedString(key: key,
                                             table: tableName,
                                             value: nil,
                                             locale: locale,
                                             location: location,
                                             comment: comment)
                strings.append(string)
            }
        }

        return strings
    }

    private func translatedLocales(of entry: [String: Any], sourceLanguage: String?) -> [String] {

        let localizations = entry["localizations"] as? [String: Any] ?? [:]

        var locales = [String]()
        for (locale, localization) in localizations {
            guard let content = localization as? [String: Any], !content.isEmpty else { continue }
            locales.append(locale)
        }

        if let sourceLanguage = sourceLanguage, !locales.contains(sourceLanguage) {
            locales.append(sourceLanguage)
        }

        return locales.sorted()
    }

    private func lineNumbers(in file: File, for entries: [String: Any]) -> [String: Int] {

        let escapedKeyPairs = entries.keys.map { (self.escaped($0), $0) }
        let escapedKeys = Dictionary(escapedKeyPairs, uniquingKeysWith: { first, _ in first })

        var lineNumbers = [String: Int]()

        let lines = file.lines.enumerated()

        for (index, line) in lines {
            guard let name = self.objectName(in: line) else { continue }
            guard let key = escapedKeys[name] else { continue }

            lineNumbers[key] = index + 1
        }

        return lineNumbers
    }

    private func escaped(_ key: String) -> String {
        return key
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
    }

    // match `"some_key" : {`.
    private static let objectNamePattern = try? NSRegularExpression(pattern: #"^\s*"(.*)"\s*:\s*\{\s*$"#)

    private func objectName(in line: String) -> String? {

        guard let pattern = XCStringsParser.objectNamePattern else { return nil }

        let range = NSRange(line.startIndex..., in: line)
        guard let match = pattern.firstMatch(in: line, range: range) else { return nil }

        let captureRange = match.range(at: 1)
        guard let nameRange = Range(captureRange, in: line) else { return nil }

        let name = line[nameRange]
        return String(name)
    }
}
