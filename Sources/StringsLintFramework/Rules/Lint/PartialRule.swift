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
    
    private var locales = [Locale]()
    private var declaredStrings = [Locale: [LocalizedString]]()
    
    public required convenience init() {
        self.init(parser: StringsParser())
    }
    
    public required convenience init(configuration: Any) throws {
        self.init(parser: try StringsParser.self.init(configuration: configuration))
    }

    public init(parser: LocalizableParser) {
        self.parser = parser
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
                    return self.buildViolation(location: string.location, locale: otherLocale)
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
    
    private func buildViolation(location: Location, locale: Locale) -> Violation {
        return Violation(ruleDescription: PartialRule.description, severity: .warning, location: location, reason: "Localized string is missing in locale \(locale)")
    }
}
