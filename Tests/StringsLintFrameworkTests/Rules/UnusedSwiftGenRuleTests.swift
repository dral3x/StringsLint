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

  func testHelpLink() throws {

    let stringsFile = File(
      name: "Localizable.strings",
      content: """
          \"abc\" = \"A B C\";
"""
    )

    let usageFile = File(name: "hi.swift", content: """
let myVar = abc
""")

    let stringsLintConfig = [
      "unused_swiftgen_strings": [
        "severity": "warning",
        "help_link": "www.faire.com"
      ]
    ]

    let rule = try UnusedSwiftGenRule(configuration: stringsLintConfig)

    rule.processFile(stringsFile)
    rule.processFile(usageFile)

    XCTAssertEqual(rule.violations[0].description, "<nopath>:1: warning: Unused SwiftGen String Violation: Localized string \"abc\" is unused. If you intend to use this string in a later PR, please add it to the \"work_in_progress\" list in .stringslint.yml or create a new \".ignore.yml\" file. For more information, please see: www.faire.com (unused_swiftgen_strings)")
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

  func testStringWIPYaml() throws {
    let stringsFile = File(
      name: "Localizable.strings",
      content: """
          \"PRODUCT_DETAILS.INFO_SECTION.TITLE\" = \"A B C\";
"""
    )

    let usageFile = File(name: "hi.swift", content: """
""")

    let yamlFile = File(name: "my_strings.ignore.yml", content: """
directly_responsible_engineer_name:
  John Doe

work_in_progress:
  - PRODUCT_DETAILS.INFO_SECTION.TITLE
""")

    let stringsLintConfig = [
      "unused_swiftgen_strings": [
        "severity": "warning"
      ]
    ]
    let rule = try UnusedSwiftGenRule(configuration: stringsLintConfig)
    rule.processFile(stringsFile)
    rule.processFile(usageFile)
    rule.processFile(yamlFile)


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

  func testWipStringInUseViolation() throws {
    let stringsFile = File(
      name: "Localizable.strings",
      content: """
          \"PRODUCT_DETAILS.INFO_SECTION.TITLE\" = \"A B C\";
"""
    )

    let usageFile = File(name: "hi.swift", content: """
let myVar = L10n.ProductDetails.InfoSection.title
""")

    let stringsLintConfig = [
      "unused_swiftgen_strings": [
        "severity": "error",
        "work_in_progress": [
          "PRODUCT_DETAILS.INFO_SECTION.TITLE"
        ]
      ]
    ]

    let rule = try UnusedSwiftGenRule(configuration: stringsLintConfig)
    rule.processFile(stringsFile)
    rule.processFile(usageFile)

    XCTAssertEqual(rule.violations.count, 1)
    XCTAssertTrue(rule.violations[0].severity == .error)
    XCTAssertEqual(rule.violations[0].description, "<nopath>:1: error: Unused SwiftGen String Violation: This string is marked as WIP in .stringslint.yml, please remove this string from the WIP list. (unused_swiftgen_strings)")
  }

  func testStringWIPYaml_noDRE() throws {
    let stringsFile = File(
      name: "Localizable.strings",
      content: """
          \"PRODUCT_DETAILS.INFO_SECTION.TITLE\" = \"A B C\";
"""
    )

    let usageFile = File(name: "hi.swift", content: """
""")

    let yamlFile = File(name: "my_strings.ignore.yml", content: """
work_in_progress:
  - PRODUCT_DETAILS.INFO_SECTION.TITLE
""")

    let stringsLintConfig = [
      "unused_swiftgen_strings": [
        "severity": "error"
      ]
    ]
    let rule = try UnusedSwiftGenRule(configuration: stringsLintConfig)
    rule.processFile(stringsFile)
    rule.processFile(usageFile)
    rule.processFile(yamlFile)


    XCTAssertEqual(rule.violations.count, 1)
    XCTAssertTrue(rule.violations[0].severity == .error)
    XCTAssertEqual(rule.violations[0].description, """
<nopath>:1: error: Unused SwiftGen String Violation: Please specify a DRE for these strings in the following format:
directly_responsible_engineer_name:
  John Doe
 (unused_swiftgen_strings)
""")

  }

  func testWipStringInUse_yamlViolation() throws {
    let stringsFile = File(
      name: "Localizable.strings",
      content: """
          \"PRODUCT_DETAILS.INFO_SECTION.TITLE\" = \"A B C\";
"""
    )

    let usageFile = File(name: "hi.swift", content: """
let myVar = L10n.ProductDetails.InfoSection.title
""")


    let yamlFile = File(name: "my_strings.ignore.yml", content: """
directly_responsible_engineer_name:
  John Doe

work_in_progress:
  - PRODUCT_DETAILS.INFO_SECTION.TITLE
""")

    let stringsLintConfig = [
      "unused_swiftgen_strings": [
        "severity": "warning"
      ]
    ]
    let rule = try UnusedSwiftGenRule(configuration: stringsLintConfig)
    rule.processFile(stringsFile)
    rule.processFile(usageFile)
    rule.processFile(yamlFile)


    XCTAssertEqual(rule.violations.count, 1)
    XCTAssertTrue(rule.violations[0].severity == .warning)
    XCTAssertEqual(rule.violations[0].description, "<nopath>:5: warning: Unused SwiftGen String Violation: This string is marked as WIP here but is referenced at \"<nopath>:1\", please remove this string. (unused_swiftgen_strings)")
  }
}
