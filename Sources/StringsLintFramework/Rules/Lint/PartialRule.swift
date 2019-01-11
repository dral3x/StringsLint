//
//  PartialRule.swift
//  StringsLintFramework
//
//  Created by Alessandro "Sandro" Calzavara on 11/09/2018.
//

import Foundation

public class PartialRule: LintRule {
    public static var description = RuleDescription(
        identifier: "partial",
        name: "Partial",
        description: "String has not been localized on all supported locales"
    )
    
    private let parser: LocalizableParser
    var severity: ViolationSeverity
    
    private var locales = [Locale]()
    private var declaredStrings = [Locale: [LocalizedString]]()
    
    public required convenience init() {
        let config = PartialRuleConfiguration()
        self.init(parser: StringsParser(), severity: config.severity)
    }
    
    public required convenience init(configuration: Any) throws {
        var config = PartialRuleConfiguration()
        do {
            try config.apply(defaultDictionaryValue(configuration, for: PartialRule.self.description.identifier))
        } catch {}
        
        self.init(parser: try StringsParser.self.init(configuration: configuration), severity: config.severity)
    }

    public init(parser: LocalizableParser, severity: ViolationSeverity) {
        self.parser = parser
        self.severity = severity
    }
    
    public func processFile(_ file: File) {
        
        guard self.parser.support(file: file) else {
            return
        }
        
        let locale = Locale(url: file.url)
        if !self.locales.contains(locale) {
            self.locales.append(locale)
        }
        
        let strings = self.processDeclarationFile(file)
        if let knownStrings = self.declaredStrings[locale] {
            self.declaredStrings[locale] = (knownStrings + strings)
        } else {
            self.declaredStrings[locale] = strings
        }
    }
    
    public var violations: [Violation] {
        
        var violations = [Violation]()
        
        for baseLocale in self.locales {
            let baseStrings = self.declaredStrings[baseLocale] ?? []
            for otherLocale in self.locales where baseLocale != otherLocale {
                let otherStrings = self.declaredStrings[otherLocale] ?? []
                
                violations += baseStrings.difference(from: otherStrings).compactMap({ (string) -> Violation? in
                    return self.buildViolation(key: string.key, location: string.location, locale: otherLocale)
                })
            }
        }
            
        return violations
    }
    
    private func processDeclarationFile(_ file: File) -> [LocalizedString] {
        do {
            return try self.parser.parse(file: file)
        } catch let error {
            print("Unable to parse file \(file): \(error)")
            return []
        }
    }
    
    private func buildViolation(key: String, location: Location, locale: Locale) -> Violation {
        return Violation(ruleDescription: PartialRule.description, severity: self.severity, location: location, reason: "Localized string \"\(key)\" is missing in locale \"\(locale)\"")
    }
}
