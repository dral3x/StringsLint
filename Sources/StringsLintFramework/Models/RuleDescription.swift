//
//  RuleDescription.swift
//  StringsLintFramework
//
//  Created by Alessandro "Sandro" Calzavara on 11/09/2018.
//

import Foundation

public struct RuleDescription {
    public let identifier: String
    public let name: String
    public let description: String
    
    public var consoleDescription: String { return "\(name) (\(identifier)): \(description)" }
}
