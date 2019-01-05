//
//  MissingRule.swift
//  StringsLintFramework
//
//  Created by Alessandro "Sandro" Calzavara on 11/09/2018.
//

import Foundation

public class MissingRule: LintRule {
    public static var description = RuleDescription(
        identifier: "missing",
        name: "Missing",
        description: "Localized string is used but not translated"
    )
    
    private var declaredStrings = [LocalizedString]()
    private var usedStrings = [LocalizedString]()
    
    private let declareParser: LocalizableParser
    private let usageParser: LocalizableParser
    
    public required convenience init(configuration: Any) throws {
        self.init(declareParser: try StringsParser.self.init(configuration: configuration),
                  usageParser: ComposedParser(parsers: [
                    try SwiftParser.self.init(configuration: configuration),
                    try ObjcParser.self.init(configuration: configuration),
                    try XibParser.self.init(configuration: configuration)
                ])
        )
    }
    public required convenience init() {
        self.init(declareParser: StringsParser(),
                  usageParser: ComposedParser(parsers: [ SwiftParser(), ObjcParser(), XibParser() ]))
    }
    
    public init(declareParser: LocalizableParser,
                usageParser: LocalizableParser) {
        self.declareParser = declareParser
        self.usageParser = usageParser
    }
    
    public func processFile(_ file: File) {
        
        if self.declareParser.support(file: file) {
            self.declaredStrings += self.processDeclarationFile(file)
        }
        
        if self.usageParser.support(file: file) {
            self.usedStrings += self.processUsageFile(file)
        }
    }
    
    public var violations: [Violation] {
        
        let diff = self.usedStrings.difference(from: self.declaredStrings)
        
        return diff.compactMap({ (string) -> Violation? in
            return self.buildViolation(location: string.location)
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
    
    private func buildViolation(location: Location) -> Violation {
        return Violation(ruleDescription: MissingRule.description, severity: .warning, location: location, reason: "Localized string is missing")
    }
}
