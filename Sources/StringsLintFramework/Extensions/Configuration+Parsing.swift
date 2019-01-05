//
//  Configuration+Parsing.swift
//  StringsLintFramework
//
//  Created by Alessandro "Sandro" Calzavara on 11/09/2018.
//

extension Configuration {
    
    private enum Key: String {
        case excluded = "excluded"
        case included = "included"
    }

    public init?(dict: [String: Any], ruleList: RuleList = masterRuleList) {

        // Source files
        let included = defaultStringArray(dict[Key.included.rawValue])
        let excluded = defaultStringArray(dict[Key.excluded.rawValue])

        // Rules
        let configuredRules: [LintRule]
        do {
            configuredRules = try ruleList.configuredRules(with: dict)
        } catch RuleListError.duplicatedConfigurations(let ruleType) {
            let aliases = ruleType.description
            let identifier = ruleType.description.identifier
            queuedPrintError("Multiple configurations found for '\(identifier)'. Check for any aliases: \(aliases).")
            return nil
        } catch {
            return nil
        }
        
        self.init(
            included: included,
            excluded: excluded,
            rules: configuredRules
        )
    }
}
