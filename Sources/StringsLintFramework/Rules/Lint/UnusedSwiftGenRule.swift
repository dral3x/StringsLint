//
//  UnusedSwiftGenRule.swift
//  StringsLintFramework
//
//  Created by Haocen Jiang on 2022-10-17.
//

import Foundation

public class UnusedSwiftGenRule: LintRule {
  private let ignoredStrings: Set<String>
  private let wipStrings: Set<String>
  private var declaredStrings = [LocalizedString]()
  private var usedStrings = [LocalizedString]()
  private var yamlFileViolations = [Violation]()
  private var ignoreKeys = [StringIgnoreYamlParser.IgnoredStringsKey]()
  var severity: ViolationSeverity

  private let declareParser: LocalizableParser
  private let usageParser: LocalizableParser
  private let ignoreYamlParser: StringIgnoreYamlParser
  private let helpLink: String?
  private var helpLinkDescription: String {
    if let helpLink = helpLink {
      return " For more information, please see: \(helpLink)"
    } else {
      return ""
    }
  }

  public static var description = RuleDescription(
    identifier: "unused_swiftgen_strings",
    name: "Unused SwiftGen String",
    description: "L10n string is not used in the app"
  )

  public required convenience init() {
    let config = UnusedSwiftGenRuleConfiguration()
    self.init(declareParser: ComposedParser(parsers: [ StringsParser(), StringsdictParser() ]),
              usageParser: ComposedParser(parsers: [ SwiftL10nParser() ]),
              ignoredStrings: config.ignored,
              wipStrings: config.workInProgressStrings,
              severity: config.severity,
              helpLink: config.helpLink)
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
      ignoredStrings: config.ignored,
      wipStrings: config.workInProgressStrings,
      severity: config.severity,
      helpLink: config.helpLink
    )
  }

  public init(declareParser: LocalizableParser,
              usageParser: LocalizableParser,
              ignoredStrings: [String],
              wipStrings: [String],
              severity: ViolationSeverity,
              helpLink: String?) {
    self.declareParser = declareParser
    self.usageParser = usageParser
    self.ignoredStrings = Set(ignoredStrings.map { $0.toL10nGenerated() })
    self.wipStrings = Set(wipStrings.map { $0.toL10nGenerated() })
    self.ignoreYamlParser = .init(severity: severity)
    self.severity = severity
    self.helpLink = helpLink
  }

  public func processFile(_ file: File) {
    if self.declareParser.support(file: file) {
      self.declaredStrings += self.processDeclarationFile(file)
    }

    if self.usageParser.support(file: file) {
      self.usedStrings += self.processUsageFile(file)
    }

    if ignoreYamlParser.supports(file: file) {
      parseIgnoreYamlFile(file)
    }
  }

  public var violations: [Violation] {
    buildUnusedStringViolations() + buildWIPStringViolations() + yamlFileViolations
  }

  private func buildUnusedStringViolations() -> [Violation] {
    let diff = declaredStrings
      .filter { string in
        !ignoredStrings.contains(string.key) &&
        !wipStrings.contains(string.key) &&
        !ignoreKeys.contains {
          $0.key.toL10nGenerated() == string.key
        }
      }
      .difference(from: self.usedStrings)

    return diff.compactMap({ (string) -> Violation? in
      buildViolation(key: string.key, location: string.location, comment: string.comment)
    })
  }

  private func buildWIPStringViolations() -> [Violation] {
    usedStrings.compactMap { string -> Violation? in
      if wipStrings.contains(string.key) {
        return Violation(
          ruleDescription: UnusedSwiftGenRule.description,
          severity: severity,
          location: string.location,
          reason: "This string is marked as WIP in .stringslint.yml, please remove this string from the WIP list.\(helpLinkDescription)"
        )
      }

      if let ignoreKey = ignoreKeys.first(where: {$0.key.toL10nGenerated() == string.key }) {
        return Violation(
          ruleDescription: UnusedSwiftGenRule.description,
          severity: severity,
          location: ignoreKey.location,
          reason: "This string is marked as WIP here but is referenced at \"\(string.location)\", please remove this string.\(helpLinkDescription)"
        )
      }
      return nil
    }
  }

  private func parseIgnoreYamlFile(_ file: File){
    do {
      let (violations, keys) = try ignoreYamlParser.parseFile(file: file)
      yamlFileViolations += violations
      ignoreKeys += keys
    } catch {
    }
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
      reason: "Localized string \"\(comment)\" is unused. If you intend to use this string in a later PR, please add it to the \"work_in_progress\" list in .stringslint.yml or create a new \".ignore.yml\" file.\(helpLinkDescription)"
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
