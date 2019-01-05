//
//  RuleConfiguration.swift
//  StringsLintFramework
//
//  Created by Alessandro "Sandro" Calzavara on 01/11/2018.
//

public protocol RuleConfiguration : CustomStringConvertible {
    mutating func apply(_ configuration: Any) throws
}
