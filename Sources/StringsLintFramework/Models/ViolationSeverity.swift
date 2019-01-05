//
//  ViolationSeverity.swift
//  StringsLintFramework
//
//  Created by Alessandro "Sandro" Calzavara on 11/09/2018.
//

import Foundation

public enum ViolationSeverity: String, Comparable {
    case warning
    case error
}

// MARK: Comparable
public func < (lhs: ViolationSeverity, rhs: ViolationSeverity) -> Bool {
    return lhs == .warning && rhs == .error
}
