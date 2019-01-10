//
//  ViolationSeverity.swift
//  StringsLintFramework
//
//  Created by Alessandro "Sandro" Calzavara on 11/09/2018.
//

import Foundation

public enum ViolationSeverity: String, Comparable {
    case note
    case warning
    case error
}

// MARK: Comparable
public func < (lhs: ViolationSeverity, rhs: ViolationSeverity) -> Bool {
    return lhs == .note && rhs == .warning ||
        lhs == .note && rhs == .error ||
        lhs == .warning && rhs == .error
}
