//
//  XcodeReporter.swift
//  StringsLintFramework
//
//  Created by Alessandro "Sandro" Calzavara on 11/09/2018.
//

import Foundation

public struct XcodeReporter: Reporter {
    
    public static let identifier = "xcode"
    
    public var description: String {
        return "Reports violations in the format Xcode uses to display in the IDE. (default)"
    }
    
    public static func generateReport(_ issues: [Violation]) -> String {
        return issues.map(generateForSingleViolation).joined(separator: "\n")
    }
    
    public static func generateForSingleViolation(_ violation: Violation) -> String {
        // {full_path_to_file}{:line}{:character}: {error,warning}: {content}
        return [
            "\(violation.location): ",
            "\(violation.severity.rawValue): ",
            "\(violation.ruleDescription.name) Violation: ",
            violation.reason,
            " (\(violation.ruleDescription.identifier))"
            ].joined()
    }
}
