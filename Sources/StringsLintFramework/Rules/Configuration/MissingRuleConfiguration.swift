//
//  MissingRuleConfiguration.swift
//  StringsLintFramework
//
//  Created by Alessandro "Sandro" Calzavara on 10/01/2019.
//

import Foundation

public struct MissingRuleConfiguration: RuleConfiguration {
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
