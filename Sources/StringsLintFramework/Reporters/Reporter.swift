//
//  Reporter.swift
//  StringsLintFramework
//
//  Created by Alessandro "Sandro" Calzavara on 11/09/2018.
//

import Foundation

public protocol Reporter: CustomStringConvertible {
    static var identifier: String { get }
    
    static func generateReport(_ issues: [Violation]) -> String
}

public func reporterFrom(identifier: String) -> Reporter.Type {
    switch identifier {
    case XcodeReporter.identifier:
        return XcodeReporter.self
    default:
        queuedFatalError("no reporter with identifier '\(identifier)' available.")
    }
}
