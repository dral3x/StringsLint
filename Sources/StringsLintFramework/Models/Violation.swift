//
//  Violation.swift
//  StringsLintFramework
//
//  Created by Alessandro "Sandro" Calzavara on 11/09/2018.
//

import Foundation

public struct Violation {
    public let ruleDescription: RuleDescription
    public let severity: ViolationSeverity
    public let location: Location
    public let reason: String
    
    public var description: String {
        return XcodeReporter.generateForSingleViolation(self)
    }
}
