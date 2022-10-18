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
    file.lines
      .enumerated()
      .flatMap {
        extractL10nUsage(from: $0.element, location: Location(file: file, line: $0.offset+1))
      }
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
    static let L10nPattern = #"L10n\.[a-zA-Z0-9.]+"#
  }

  func extractL10nUsage(from content: String, location: Location) -> [LocalizedString] {
    do {
      let regex = try NSRegularExpression(pattern: Constants.L10nPattern)

      let results = regex.matches(
        in: content,
        range: NSRange(content.startIndex..., in: content)
      )

      return results.map {
        LocalizedString(
          key: String(content[Range($0.range, in: content)!]),
          table: tableName,
          locale: .none,
          location: location
        )
      }
    } catch let error {
      print("invalid regex: \(error.localizedDescription)")
      return []
    }
  }
}
