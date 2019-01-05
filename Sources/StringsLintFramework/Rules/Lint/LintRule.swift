//
//  LintRule.swift
//  StringsLintFramework
//
//  Created by Alessandro "Sandro" Calzavara on 11/09/2018.
//

import Foundation

public protocol LintRule {
    static var description: RuleDescription { get }
    
    init() // Rules need to be able to be initialized with default values
    init(configuration: Any) throws
    
    func processFile(_ file: File)
    
    var violations: [Violation] { get }
}
