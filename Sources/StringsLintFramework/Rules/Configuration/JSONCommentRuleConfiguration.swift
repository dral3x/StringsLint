//
//  JSONCommentRuleConfiguration.swift
//  StringsLintFramework
//
//  Created by Mark Hall on 2022-07-18.
//

import Foundation

public struct JSONCommentRuleConfiguration: RuleConfiguration {
    public var description: String {
        return "severity: \(self.severity)"
    }

    //TODO: (Mark Hall, July 18) once we have all the existing strings converted to the new comment format, make this an error severity
    public var severity: ViolationSeverity = .warning

    public mutating func apply(_ configuration: Any) throws {

        guard let configuration = configuration as? [String: Any] else {
            throw ConfigurationError.unknownConfiguration
        }

        self.severity = ViolationSeverity(rawValue: configuration["severity"] as! String) ?? self.severity
    }

}
