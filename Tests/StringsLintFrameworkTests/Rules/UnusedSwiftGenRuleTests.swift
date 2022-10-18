//
//  UnusedSwiftGenRuleTests.swift
//  
//
//  Created by Haocen Jiang on 2022-10-18.
//

import XCTest
@testable import StringsLintFramework

final class UnusedSwiftGenRuleTests: XCTestCase {
  func testStringWithUsage() {

    let stringsFile = File(
      name: "Localizable.strings",
      content: """
          \"abc\" = \"A B C\";
"""
    )

    let usageFile = File(name: "hi.swift", content: """
let myVar = L10n.abc
""")

    let rule = UnusedSwiftGenRule()
    rule.processFile(stringsFile)
    rule.processFile(usageFile)

    XCTAssertEqual(rule.violations.count, 0)
  }

  func testStringWithNoUsage() {

    let stringsFile = File(
      name: "Localizable.strings",
      content: """
          \"abc\" = \"A B C\";
"""
    )

    let usageFile = File(name: "hi.swift", content: """
let myVar = abc
""")

    let rule = UnusedSwiftGenRule()
    rule.processFile(stringsFile)
    rule.processFile(usageFile)

    XCTAssertEqual(rule.violations.count, 1)
  }

  func testStringWithNestedUsage() {

    let stringsFile = File(
      name: "Localizable.strings",
      content: """
          \"PRODUCT_DETAILS.INFO_SECTION.TITLE\" = \"A B C\";
"""
    )

    let usageFile = File(name: "hi.swift", content: """
let myVar = L10n.ProductDetails.InfoSection.title
""")

    let rule = UnusedSwiftGenRule()
    rule.processFile(stringsFile)
    rule.processFile(usageFile)

    XCTAssertEqual(rule.violations.count, 0)
  }

  func testStringWIP() throws {
    let stringsFile = File(
      name: "Localizable.strings",
      content: """
          \"PRODUCT_DETAILS.INFO_SECTION.TITLE\" = \"A B C\";
"""
    )

    let usageFile = File(name: "hi.swift", content: """
""")

    let stringsLintConfig = [
      "unused_swiftgen_strings": [
        "severity": "warning",
        "work_in_progress": ["PRODUCT_DETAILS.INFO_SECTION.TITLE"]
      ]
    ]
    let rule = try UnusedSwiftGenRule(configuration: stringsLintConfig)
    rule.processFile(stringsFile)
    rule.processFile(usageFile)


    XCTAssertEqual(rule.violations.count, 0)
  }

  func testVialtionIsError() throws {
    let stringsFile = File(
      name: "Localizable.strings",
      content: """
          \"PRODUCT_DETAILS.INFO_SECTION.TITLE\" = \"A B C\";
"""
    )

    let usageFile = File(name: "hi.swift", content: """
""")

    let stringsLintConfig = [
      "unused_swiftgen_strings": [
        "severity": "warning"
      ]
    ]
    let rule = try UnusedSwiftGenRule(configuration: stringsLintConfig)
    rule.processFile(stringsFile)
    rule.processFile(usageFile)


    XCTAssertEqual(rule.violations.count, 1)
    XCTAssertTrue(rule.violations[0].severity == .warning)
  }

  func testVialtionIsWarning() throws {
    let stringsFile = File(
      name: "Localizable.strings",
      content: """
          \"PRODUCT_DETAILS.INFO_SECTION.TITLE\" = \"A B C\";
"""
    )

    let usageFile = File(name: "hi.swift", content: """
""")

    let stringsLintConfig = [
      "unused_swiftgen_strings": [
        "severity": "error"
      ]
    ]
    let rule = try UnusedSwiftGenRule(configuration: stringsLintConfig)
    rule.processFile(stringsFile)
    rule.processFile(usageFile)


    XCTAssertEqual(rule.violations.count, 1)
    XCTAssertTrue(rule.violations[0].severity == .error)
  }

}
