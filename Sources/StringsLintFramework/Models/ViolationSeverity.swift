//
//  ViolationSeverity.swift
//  StringsLintFramework
//
//  Created by Alessandro "Sandro" Calzavara on 11/09/2018.
//

import Foundation

public enum ViolationSeverity: String, Comparable {
    /// Ignored. No report will contain any violation of this severity.
    case none
    /// Non-fatal. If using StringsLint as an Xcode build phase, Xcode will mark the build as having succeeded.
    case warning
    /// Fatal. If using StringsLint as an Xcode build phase, Xcode will mark the build as having failed.
    case error
}

// MARK: Comparable
public func < (lhs: ViolationSeverity, rhs: ViolationSeverity) -> Bool {
    return lhs == .none && rhs == .warning ||
        lhs == .none && rhs == .error ||
        lhs == .warning && rhs == .error
}
