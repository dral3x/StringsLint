//
//  UnusedSwiftGenRuleConfiguration.swift
//  StringsLintFramework
//
//  Created by Haocen Jiang on 2022-10-17.
//

import Foundation

import Foundation

public struct UnusedSwiftGenRuleConfiguration: RuleConfiguration {
  public var description: String {
    return "severity: \(self.severity), ignored: \(self.ignored), wipStrings: \(self.workInProgressStrings)"
  }

  public var severity: ViolationSeverity = .warning
  public var workInProgressStrings = [String]()
  public var ignored = [String]()

  public mutating func apply(_ configuration: Any) throws {

    guard let configuration = configuration as? [String: Any] else {
      throw ConfigurationError.unknownConfiguration
    }

    self.severity = ViolationSeverity(rawValue: configuration["severity"] as! String) ?? self.severity
    self.ignored += defaultStringArray(configuration["ignored"])
    self.workInProgressStrings += defaultStringArray(configuration["work_in_progress"])
  }
}
