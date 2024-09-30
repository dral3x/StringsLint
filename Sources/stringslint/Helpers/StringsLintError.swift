//
//  StringsLintError.swift
//  StringsLint
//
//  Created by Alessandro Calzavara on 30/09/24.
//

import Foundation

enum StringsLintError: LocalizedError {
    case usageError(description: String)

    var errorDescription: String? {
        switch self {
        case .usageError(let description):
            return description
        }
    }
}
