//
//  MissingRuleTests.swift
//  StringsLintFrameworkTests
//
//  Created by Alessandro Calzavara on 15/09/23.
//

import XCTest
@testable import StringsLintFramework

final class MissingRuleTests: XCTestCase {

    func testMissingExample() {

        let file = File(name: "MainView.swift", content: "Text(\"Banana\")")

        let rule = MissingRule()
        rule.processFile(file)

        XCTAssertEqual(rule.violations.count, 1)
        XCTAssertEqual(rule.violations[0].severity, .warning)
    }

    func testIgnoredStrings() {

        let file = File(name: "MainView.swift", content: "Text(\"This is a test\")")

        let rule = MissingRule(ignored: ["This is a test"])
        rule.processFile(file)

        XCTAssertEqual(rule.violations.count, 0)
    }

    func testStringWithValueShouldNotTrigger() {

        let file = File(name: "MainView.swift", content: "NSLocalizedString(\"abc\", value: \"v\", comment: \"blabla\")")

        let rule = MissingRule()
        rule.processFile(file)

        XCTAssertEqual(rule.violations.count, 0)
    }

    func testStringCatalogDeclarationSatisfiesUsage() {
        let content = XCStringsFixture.catalog(key: "abc")
        let catalog = File(name: "Localizable.xcstrings", content: content)
        let code = File(name: "main.swift", content: "NSLocalizedString(\"abc\", comment: \"\")")

        let rule = MissingRule()
        rule.processFile(catalog)
        rule.processFile(code)

        XCTAssertEqual(rule.violations.count, 0)
    }

    func testUsageMissingFromStringCatalog() {
        let content = XCStringsFixture.catalog(key: "abc")
        let catalog = File(name: "Localizable.xcstrings", content: content)
        let code = File(name: "main.swift", content: "NSLocalizedString(\"def\", comment: \"\")")

        let rule = MissingRule()
        rule.processFile(catalog)
        rule.processFile(code)

        XCTAssertEqual(rule.violations.map { $0.reason }, [ "Localized string \"def\" is missing" ])
    }
}
