//
//  UnusedRuleConfiguration.swift
//  StringsLintFramework
//
//  Created by Alessandro "Sandro" Calzavara on 01/11/2018.
//

import Foundation

public struct UnusedRuleConfiguration: RuleConfiguration {
    public var description: String {
        return "enabled: \(self.enabled), ignored: \(self.ignored)"
    }
    
    public var enabled: Bool = true
    
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

        self.enabled = configuration["enabled"] as? Bool ?? self.enabled
        self.ignored += defaultStringArray(configuration["ignored"])
    }
    
}
