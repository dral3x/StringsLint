//
//  UnusedRuleConfiguration.swift
//  StringsLintFramework
//
//  Created by Alessandro "Sandro" Calzavara on 01/11/2018.
//

import Foundation

public struct UnusedRuleConfiguration: RuleConfiguration {
    public var description: String {
        return "severity: \(self.severity), ignored: \(self.ignored)"
    }
    
    public var severity: ViolationSeverity = .warning
    
    // strings to always consider as used
    public var ignored: [String] = [
        "NSCameraUsageDescription",
        "NSHumanReadableCopyright",
        "NSMicrophoneUsageDescription",
        "NSPhotoLibraryUsageDescription",
    ]
    
    public mutating func apply(_ configuration: Any) throws {
        
        guard let configuration = configuration as? [String: Any] else {
            throw ConfigurationError.unknownConfiguration
        }

        self.severity = ViolationSeverity(rawValue: configuration["severity"] as! String) ?? self.severity
        self.ignored += defaultStringArray(configuration["ignored"])
    }
    
}
