//
//  UnusedSwiftGenRule.swift
//  StringsLintFramework
//
//  Created by Haocen Jiang on 2022-10-17.
//

import Foundation

public class UnusedSwiftGenRule: LintRule {
  private let ignoredStrings: Set<String>
  private var declaredStrings = [LocalizedString]()
  private var usedStrings = [LocalizedString]()
  var severity: ViolationSeverity

  private let declareParser: LocalizableParser
  private let usageParser: LocalizableParser

  public static var description = RuleDescription(
    identifier: "unused_swiftgen_strings",
    name: "Unused SwiftGen String",
    description: "L10n string is not used in the app"
  )

  public required convenience init() {
    let config = UnusedSwiftGenRuleConfiguration()
    self.init(declareParser: ComposedParser(parsers: [ StringsParser(), StringsdictParser() ]),
              usageParser: ComposedParser(parsers: [ SwiftL10nParser() ]),
              ignoredStrings: config.workInProgressStrings + config.ignored,
              severity: config.severity)
  }

  public required convenience init(configuration: Any) throws {
    var config = UnusedSwiftGenRuleConfiguration()
    do {
      try config.apply(defaultDictionaryValue(configuration, for: UnusedSwiftGenRule.self.description.identifier))
    } catch { }

    self.init(
      declareParser: ComposedParser(parsers: [
        try StringsParser.self.init(configuration: configuration),
        try StringsdictParser.self.init(configuration: configuration)
      ]),
      usageParser: ComposedParser(parsers: [
        try SwiftL10nParser.self.init(configuration: configuration)
      ]),
      ignoredStrings: config.workInProgressStrings + config.ignored,
      severity: config.severity
    )
  }

  public init(declareParser: LocalizableParser,
              usageParser: LocalizableParser,
              ignoredStrings: [String],
              severity: ViolationSeverity) {
    self.declareParser = declareParser
    self.usageParser = usageParser
    self.ignoredStrings = Set(ignoredStrings.map { $0.toL10nGenerated() })
    self.severity = severity
  }

  public func processFile(_ file: File) {
    if self.declareParser.support(file: file) {
      self.declaredStrings += self.processDeclarationFile(file)
        .filter { !self.ignoredStrings.contains($0.key) }
    }

    if self.usageParser.support(file: file) {
      self.usedStrings += self.processUsageFile(file)
    }
  }

  public var violations: [Violation] {

    let diff = self.declaredStrings.difference(from: self.usedStrings)

    return diff.compactMap({ (string) -> Violation? in
      return self.buildViolation(key: string.key, location: string.location, comment: string.comment)
    })
  }

  private func processDeclarationFile(_ file: File) -> [LocalizedString] {
    do {
      return try self.declareParser.parse(file: file)
        .map {
          LocalizedString(
            key: $0.key.toL10nGenerated(),
            table: $0.table,
            locale: $0.locale,
            location: $0.location,
            comment: $0.key
          )
        }
    } catch let error {
      print("Unable to parse file \(file): \(error)")
      return []
    }
  }

  private func processUsageFile(_ file: File) -> [LocalizedString] {
    do {
      return try self.usageParser.parse(file: file)
        .map {
          LocalizedString(
            key: $0.key.lowercased(),
            table: $0.table,
            locale: $0.locale,
            location: $0.location
          )
        }
    } catch let error {
      print("Unable to parse file \(file): \(error)")
      return []
    }
  }

  private func buildViolation(key: String, location: Location, comment: String?) -> Violation? {
    guard let comment = comment else { return nil }

    return Violation(
      ruleDescription: UnusedSwiftGenRule.description,
      severity: self.severity,
      location: location,
      reason: "Localized string \"\(comment)\" is unused."
    )
  }
}


extension String {
  func toL10nGenerated() -> String {
    let splitArray = split(separator: ".")

    let generated = splitArray
      .enumerated()
      .map {
        String($0.element).toCamelCase(cap: $0.offset != splitArray.endIndex - 1 && splitArray.count != 1)
      }
      .joined(separator: ".")

    return "L10n.\(generated)".lowercased()
  }

  func toCamelCase(cap: Bool) -> Self {
    lowercased()
      .split(separator: "_")
      .enumerated()
      .map { ($0.offset > 0 || cap) ? $0.element.capitalized : $0.element.lowercased() }
      .joined()
  }

}
