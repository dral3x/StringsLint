//
//  MissingCommentRuleConfiguration.swift
//  StringsLintFramework
//
//  Created by Eidinger, Marco on 6/25/21.
//

import Foundation

public struct MissingCommentRuleConfiguration: RuleConfiguration {
    public var description: String {
        return "severity: \(self.severity)"
    }

    public var severity: ViolationSeverity = .warning

    public mutating func apply(_ configuration: Any) throws {

        guard let configuration = configuration as? [String: Any] else {
            throw ConfigurationError.unknownConfiguration
        }

        self.severity = ViolationSeverity(rawValue: configuration["severity"] as! String) ?? self.severity
    }

}
