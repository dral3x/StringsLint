//
//  MissingCommentRule.swift
//  StringsLintFramework
//
//  Created by Eidinger, Marco on 6/25/21.
//

import Foundation

public class MissingCommentRule: LintRule {
    public static var description = RuleDescription(
        identifier: "missingComment",
        name: "MissingComment",
        description: "Comemnt for Localized string is missing"
    )

    private var declaredStrings = [LocalizedString]()
    private var usedStrings = [LocalizedString]()
    var severity: ViolationSeverity

    private let declareParser: LocalizableParser
    private let usageParser: LocalizableParser

    public required convenience init(configuration: Any) throws {
        var config = MissingCommentRuleConfiguration()
        do {
            try config.apply(defaultDictionaryValue(configuration, for: MissingCommentRule.self.description.identifier))
        } catch {}

        self.init(declareParser: ComposedParser(parsers: [
                    try StringsParser.self.init(configuration: configuration)
                    ]),
                  usageParser: ComposedParser(parsers: []),
                  severity: config.severity
        )
    }
    public required convenience init() {
        let config = MissingRuleConfiguration()

        self.init(declareParser: StringsParser(),
                  usageParser: ComposedParser(parsers: []),
                  severity: config.severity)
    }

    public init(declareParser: LocalizableParser,
                usageParser: LocalizableParser,
                severity: ViolationSeverity) {
        self.declareParser = declareParser
        self.usageParser = usageParser
        self.severity = severity
    }

    public func processFile(_ file: File) {

        if self.declareParser.support(file: file) {
            self.declaredStrings += self.processDeclarationFile(file)
        }
    }

    public var violations: [Violation] {
        return self.declaredStrings.filter({$0.comment == nil}).compactMap({ (string) -> Violation? in
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

    private func buildViolation(key: String, location: Location) -> Violation {
        return Violation(ruleDescription: MissingCommentRule.description, severity: self.severity, location: location, reason: "Comment for Localized string \"\(key)\" is missing")
    }
}

