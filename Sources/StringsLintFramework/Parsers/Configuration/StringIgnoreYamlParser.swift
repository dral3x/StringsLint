//
//  StringIgnoreYamlParser.swift
//  
//
//  Created by Haocen Jiang on 2022-10-19.
//

import Foundation

struct StringIgnoreYamlParser {
  var severity: ViolationSeverity

  init(severity: ViolationSeverity = .warning) {
    self.severity = severity
  }

  struct IgnoredStringsKey {
    let key: String
    let location: Location
  }

  func supports(file: File) -> Bool {
    file.name.hasSuffix(".ignore.yml")
  }

  func parseFile(file: File) throws -> ([Violation], [IgnoredStringsKey]) {
    let data = try YamlParser.parse(file.content)
    var _fileViolations = [Violation]()
    var _wipStrings = Set<String>()

    if data["directly_responsible_engineer_name"] == nil {
      _fileViolations.append(
        Violation(
          ruleDescription: UnusedSwiftGenRule.description,
          severity: severity,
          location: Location(file: file),
          reason: """
Please specify a DRE for these strings in the following format:
directly_responsible_engineer_name:
  John Doe
"""
        )
      )
    }

    if let wipStrings = data["work_in_progress"] as? [String] {
      _wipStrings = Set(wipStrings)
    }

    let lineNumberMap = [String: Location](
      uniqueKeysWithValues: file.lines.enumerated().compactMap { line -> (String, Location)? in
        let maybeKey = line.element.trimmingCharacters(in: CharacterSet.whitespaces.union(CharacterSet(["-"])))
        if _wipStrings.contains(maybeKey) {
          return (maybeKey, Location(file: file, line: line.offset+1))
        }

        return nil
      }
    )

    let ignoredStringsKeys = _wipStrings.compactMap { (string) -> IgnoredStringsKey? in
      guard let location = lineNumberMap[string] else { return nil }
      return IgnoredStringsKey(key: string, location: location)
    }

    return (
      _fileViolations,
      ignoredStringsKeys
    )
  }
}
