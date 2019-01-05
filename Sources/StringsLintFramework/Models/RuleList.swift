//
//  RuleList.swift
//  StringsLintFramework
//
//  Created by Alessandro "Sandro" Calzavara on 01/11/2018.
//

public enum RuleListError: Error {
    case duplicatedConfigurations(rule: LintRule.Type)
}

public struct RuleList {
    public let list: [String: LintRule.Type]
    
    public init(rules: LintRule.Type...) {
        self.init(rules: rules)
    }
    
    public init(rules: [LintRule.Type]) {
        var tmpList = [String: LintRule.Type]()
        
        for rule in rules {
            let identifier = rule.description.identifier
            tmpList[identifier] = rule
        }
        
        list = tmpList
    }
    
    internal func configuredRules(with dictionary: [String: Any]) throws -> [LintRule] {
        var rules = [String: LintRule]()
        
        for (identifier, ruleType) in list {
            do {
                let configuredRule = try ruleType.init(configuration: dictionary)
                rules[identifier] = configuredRule
            } catch {
                queuedPrintError("Invalid configuration for '\(identifier)'. Falling back to default.")
                rules[identifier] = ruleType.init()
            }
            
        }
        
        return Array(rules.values)
    }
}
