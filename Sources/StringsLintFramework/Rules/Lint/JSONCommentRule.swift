//
//  JSONCommentRule.swift
//  StringsLintFramework
//
//  Created by Mark Hall on 2022-07-18.
//

import Foundation

public class JSONCommentRule {
    private var declaredStrings = [LocalizedString]()
    var severity: ViolationSeverity

    private let declareParser: LocalizableParser

    private var validPlaceholders = Set([
        "number",
        "date",
        "time",
        "money",
        "company_name",
        "formatting",
        "fully_translated_sentence",
        "person_name",
        "currency_code",
        "event_name",
        "email_address",
        "tariff_code",
        "tracking_code",
        "token",
        "sku",
        "month",
        "day"
    ])

    public init(declareParser: LocalizableParser,
                severity: ViolationSeverity) {
        self.declareParser = declareParser
        self.severity = severity
    }

    public required convenience init(configuration: Any) throws {
        var config = JSONCommentRuleConfiguration()
        do {
            try config.apply(defaultDictionaryValue(configuration, for: JSONCommentRule.self.description.identifier))
        } catch { }

        self.init(declareParser: ComposedParser(parsers: [try StringsdictParser.self.init(configuration: configuration),
                                                          try StringsJSONCommentParser.self.init(configuration: configuration)]),
                  severity: config.severity)
    }

    public required convenience init() {
        let config = JSONCommentRuleConfiguration()

        self.init(declareParser: ComposedParser(parsers: [StringsdictParser(),
                                                          StringsJSONCommentParser()]),
                  severity: config.severity)
    }

    private func processDeclarationFile(_ file: File) -> [LocalizedString] {
        do {
            return try self.declareParser.parse(file: file)
        } catch let error {
            print("Unable to parse file \(file): \(error)")
            return []
        }
    }
}

extension JSONCommentRule: LintRule {
    public static var description = RuleDescription(
        identifier: "json_comment_rule",
        name: "JSONCommentRule",
        description: "Placeholder comment is incorrect"
    )

    public func processFile(_ file: File) {
        if self.declareParser.support(file: file) {
            self.declaredStrings += self.processDeclarationFile(file)
        }
    }

    public var violations: [Violation] {
        var _violations = [Violation]()
        let lock = NSLock()

        DispatchQueue.concurrentPerform(iterations: self.declaredStrings.count) { index in
            let string = self.declaredStrings[index]
            if let violationType = getViolation(for: string) {
                lock.lock()
                _violations.append(
                    Violation(
                        ruleDescription: JSONCommentRule.description,
                        severity: self.severity,
                        location: string.location,
                        reason: "Comment for Localized string \"\(string.key)\" \(violationType.reasonDescription)"
                    )
                )

                lock.unlock()

            }
        }

        return _violations
    }

  private func getViolation(for string: LocalizedString) -> ViolationType? {
    guard let jsonData = string.comment?.data(using: String.Encoding.utf8),
          let jsonComment = try? JSONDecoder().decode(PlaceholderComment.self, from: jsonData) else {
        return .invalidJSON
    }

    guard let description = jsonComment.descriptionString else {
        return .missingDescription
    }

    guard !description.isEmpty else {
        return .emptyDescription
    }

    if let placeholders = jsonComment.placeholders {
        let invalidPlaceholders = Set(placeholders).subtracting(validPlaceholders)
        if !invalidPlaceholders.isEmpty {
            return .containsInvalidPlaceholders(invalidPlaceholders: invalidPlaceholders)
        }
    }

    guard jsonComment.placeholders?.count ?? 0 == string.placeholders.count else {
        return .placeholderCountsDontMatch
    }

    return nil
  }
}


extension JSONCommentRule {
    enum ViolationType {
        case invalidJSON
        case missingDescription
        case emptyDescription
        case containsInvalidPlaceholders(invalidPlaceholders: Set<String>)
        case placeholderCountsDontMatch

        var reasonDescription: String {
            switch self {
            case .invalidJSON:
                return "is not valid JSON"
            case .missingDescription:
                return "is missing the `description`"
            case .emptyDescription:
                return "has an empty `description`"
            case .containsInvalidPlaceholders(let invalidPlaceholders):
                return "contains invalid placeholders: \"\(invalidPlaceholders.joined(separator: "\", \""))\""
            case .placeholderCountsDontMatch:
                return "number of placeholders don't match"

            }
        }
    }

    fileprivate struct PlaceholderComment: Decodable {
        let descriptionString: String?
        let placeholders: [String]?

        enum CodingKeys: String, CodingKey {
            case descriptionString = "description"
            case placeholders
        }
    }
}
