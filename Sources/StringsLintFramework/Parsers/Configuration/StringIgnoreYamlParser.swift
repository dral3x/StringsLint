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

  enum IgnoreYamlFileVioationType {
    case noDRE(Location)
  }

  func supports(file: File) -> Bool {
    file.name.hasSuffix(".ignore.yml")
  }

  func parseFile(file: File) throws -> ([IgnoreYamlFileVioationType], [IgnoredStringsKey]) {
    let data = try YamlParser.parse(file.content)
    var _fileViolations = [IgnoreYamlFileVioationType]()
    var _wipStrings = Set<String>()

    if data["directly_responsible_engineer_name"] == nil {
      _fileViolations.append(.noDRE(Location(file: file)))
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
