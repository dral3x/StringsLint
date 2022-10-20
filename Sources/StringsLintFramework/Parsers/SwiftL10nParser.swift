//
//  SwiftL10nParser.swift
//  StringsLintFramework
//
//  Created by Haocen Jiang on 2022-10-17.
//

import Foundation

public struct SwiftL10nParser: LocalizableParser {
  // MARK: Public
  public static let identifier = "swift_l10n_parser"
  public let supportedFileExtentions = ["swift"]

  public init() {
    self.init(tableName: SwiftL10nParserConfiguration().tableName)
  }

  public init(configuration: Any) throws {
    var config = SwiftL10nParserConfiguration()
    do {
      try config.apply(defaultDictionaryValue(configuration, for: SwiftL10nParser.identifier))
    } catch {}

    self.init(tableName: config.tableName)
  }

  public func support(file: File) -> Bool {
    file.name.hasSuffix(".swift")
  }

  public func parse(file: File) throws -> [LocalizedString] {
    let lineNumberMap = getLineNumberMap(for: file)
    return extractL10nUsage(from: file, lineNumberMap: lineNumberMap)
  }

  // MARK: Internal
  init(tableName: String) {
      self.tableName = tableName
  }

  // MARK: Private
  private let tableName: String
}

private extension SwiftL10nParser {
  enum Constants {
    static let L10nPattern = #"L10n((\n\s*)?\.[a-zA-Z0-9.]+)+"#
  }

  /// Maps the match order to file number
  func getLineNumberMap(for file: File) -> [Int: Int] {
    var counter = 0
    var map = [Int: Int]()
    for (idx, line) in file.lines.enumerated() {
      let regex = try! NSRegularExpression(pattern: #"L10n\."#)
      for _ in regex.matches(in: line, range: NSRange(line.startIndex..., in: line)) {
        map[counter] = idx+1
        counter += 1
      }

    }

    return map
  }

  func extractL10nUsage(from file: File, lineNumberMap: [Int: Int]) -> [LocalizedString] {
    let content = file.content
    do {
      let regex = try NSRegularExpression(pattern: Constants.L10nPattern)

      let results = regex.matches(
        in: content,
        range: NSRange(content.startIndex..., in: content)
      )

      return results
        .enumerated()
        .compactMap { match -> LocalizedString? in
          guard let lineNumber = lineNumberMap[match.offset] else { return nil }
          return LocalizedString(
            key: String(content[Range(match.element.range, in: content)!]).filter {
              CharacterSet.alphanumerics.union(CharacterSet(charactersIn: ".")).containsUnicodeScalars(of: $0)
            },
            table: tableName,
            locale: .none,
            location: Location(file: file, line: lineNumber)
          )
      }
    } catch let error {
      print("invalid regex: \(error.localizedDescription)")
      return []
    }
  }
}


extension CharacterSet {
    func containsUnicodeScalars(of character: Character) -> Bool {
        return character.unicodeScalars.allSatisfy(contains(_:))
    }
}
