//
//  UnusedRule.swift
//  StringsLintFramework
//
//  Created by Alessandro "Sandro" Calzavara on 11/09/2018.
//

import Foundation

public class UnusedRule: LintRule {

    public static var description = RuleDescription(
        identifier: "unused",
        name: "Unused",
        description: "Localized string is not used in the app"
    )

    private var declaredStrings = [LocalizedString]()
    private var usedStrings = [LocalizedString]()
    private let ignoredStrings: [String]
    var severity: ViolationSeverity
    
    private let declareParser: LocalizableParser
    private let usageParser: LocalizableParser
    
    public required convenience init() {
        let config = UnusedRuleConfiguration()
        self.init(declareParser: ComposedParser(parsers: [ StringsParser(), StringsdictParser() ]),
                  usageParser: ComposedParser(parsers: [ SwiftParser(), ObjcParser(), XibParser() ]),
                  ignoredStrings: config.ignored,
                  severity: config.severity)
    }
    
    public required convenience init(configuration: Any) throws {
        var config = UnusedRuleConfiguration()
        do {
            try config.apply(defaultDictionaryValue(configuration, for: UnusedRule.self.description.identifier))
        } catch {}
        
        self.init(declareParser: ComposedParser(parsers: [
            try StringsParser.self.init(configuration: configuration),
            try StringsdictParser.self.init(configuration: configuration)
            ]),
                  usageParser: ComposedParser(parsers: [
                    try SwiftParser.self.init(configuration: configuration),
                    try ObjcParser.self.init(configuration: configuration),
                    try XibParser.self.init(configuration: configuration)
                    ]),
                  ignoredStrings: config.ignored,
                  severity: config.severity)
    }
    
    public init(declareParser: LocalizableParser,
                usageParser: LocalizableParser,
                ignoredStrings: [String],
                severity: ViolationSeverity) {
        self.declareParser = declareParser
        self.usageParser = usageParser
        self.ignoredStrings = ignoredStrings
        self.severity = severity
    }
        
    public func processFile(_ file: File) {
        
        if self.declareParser.support(file: file) {
            self.declaredStrings += self.processDeclarationFile(file).filter { !self.ignoredStrings.contains($0.key) }
        }
        
        if self.usageParser.support(file: file) {
            self.usedStrings += self.processUsageFile(file)
        }
    }
    
    public var violations: [Violation] {
        
        let diff = self.declaredStrings.difference(from: self.usedStrings)
        
        return diff.compactMap({ (string) -> Violation? in
            return self.buildViolation(key: string.key, location: string.location)
        })
    }
    
    private func processDeclarationFile(_ file: File) -> [LocalizedString] {
        do {
            return try self.declareParser.parse(file: file)
        } catch let error {
            print("Unable to parse file \(file): \(error)")
            return []
        }
    }
    
    private func processUsageFile(_ file: File) -> [LocalizedString] {
        do {
            return try self.usageParser.parse(file: file)
        } catch let error {
            print("Unable to parse file \(file): \(error)")
            return []
        }
    }
    
    private func buildViolation(key: String, location: Location) -> Violation {
        return Violation(ruleDescription: UnusedRule.description, severity: self.severity, location: location, reason: "Localized string \"\(key)\" is unused")
    }
}
