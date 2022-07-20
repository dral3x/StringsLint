//
//  File.swift
//  
//
//  Created by Mark Hall on 2022-07-19.
//

import XCTest
@testable import StringsLintFramework

class StructuredPlaceholderCommentRuleTests: XCTestCase {

    func testStringWithValidComment() {

        let file = File(name: "Localizable.strings", content: """
            /*
            {
              "description": "A CTA to go to the New Arrivals shopping section, links the retailer to this category",
              "placeholders": ["person_name", "number"]
            }
             */
            "EMPTY_STATE.VIEW_BAG_BUTTON_MULTIPLE_PLACEHOLDERS" = "View Bag %@ %@";
            """)

        let rule = StructuredPlaceholderCommentRule()
        rule.processFile(file)

        XCTAssertEqual(rule.violations.count, 0)
    }

    func testStringWithMissingDescriptionInComment() {

        let file = File(name: "Localizable.strings", content: """
            /*
            {
              "placeholders": ["person_name", "number"]
            }
             */
            "EMPTY_STATE.VIEW_BAG_BUTTON_MULTIPLE_PLACEHOLDERS" = "View Bag %@ %@";
            """)

        let rule = StructuredPlaceholderCommentRule()
        rule.processFile(file)

        XCTAssertEqual(rule.violations.count, 1)
        XCTAssertEqual(rule.violations[0].severity, .warning)
    }

    func testStringWithEmptyDescriptionInComment() {

        let file = File(name: "Localizable.strings", content: """
            /*
            {
              "description": "",
              "placeholders": ["person_name", "number"]
            }
             */
            "EMPTY_STATE.VIEW_BAG_BUTTON_MULTIPLE_PLACEHOLDERS" = "View Bag %@ %@";
            """)

        let rule = StructuredPlaceholderCommentRule()
        rule.processFile(file)

        XCTAssertEqual(rule.violations.count, 1)
        XCTAssertEqual(rule.violations[0].severity, .warning)
    }

    func testStringWithInvalidPlaceholdersInComment() {

        let file = File(name: "Localizable.strings", content: """
            /*
            {
              "description": "A CTA to go to the New Arrivals shopping section, links the retailer to this category",
              "placeholders": ["person_name", "asdf"]
            }
             */
            "EMPTY_STATE.VIEW_BAG_BUTTON_MULTIPLE_PLACEHOLDERS" = "View Bag %@ %@";
            """)

        let rule = StructuredPlaceholderCommentRule()
        rule.processFile(file)

        XCTAssertEqual(rule.violations.count, 1)
        XCTAssertEqual(rule.violations[0].severity, .warning)
    }

    func testStringWithPlaceholderCountNotMatchingInComment() {

        let file = File(name: "Localizable.strings", content: """
            /*
            {
              "description": "A CTA to go to the New Arrivals shopping section, links the retailer to this category",
              "placeholders": ["person_name"]
            }
             */
            "EMPTY_STATE.VIEW_BAG_BUTTON_MULTIPLE_PLACEHOLDERS" = "View Bag %@ %@";
            """)

        let rule = StructuredPlaceholderCommentRule()
        rule.processFile(file)

        XCTAssertEqual(rule.violations.count, 1)
        XCTAssertEqual(rule.violations[0].severity, .warning)
    }

    func testStringWithInvalidComment() {

        let file = File(name: "Localizable.strings", content: """
            /*
            {
              "description": "A CTA to go to the New Arrivals shopping section, links the retailer to this category",
             */
            "EMPTY_STATE.VIEW_BAG_BUTTON_MULTIPLE_PLACEHOLDERS" = "View Bag %@ %@";
            """)

        let rule = StructuredPlaceholderCommentRule()
        rule.processFile(file)

        XCTAssertEqual(rule.violations.count, 1)
        XCTAssertEqual(rule.violations[0].severity, .warning)
    }

}
