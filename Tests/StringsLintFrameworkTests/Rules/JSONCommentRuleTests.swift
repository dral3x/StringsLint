//
//  File.swift
//  
//
//  Created by Mark Hall on 2022-07-19.
//

import XCTest
@testable import StringsLintFramework

class JSONCommentRuleTests: XCTestCase {

    func testStringWithValidComment() {

        let file = File(name: "Localizable.strings", content: """
            /*
              Retailer.strings
              Retailer

              Created by Raissa Nucci on 07/04/20.
              Copyright © 2020 Faire Inc. All rights reserved.
            */
            /*
            {
              "description": "A CTA to go to the New Arrivals shopping section, links the retailer to this category",
              "placeholders": ["person_name", "number"]
            }
             */
            "EMPTY_STATE.VIEW_BAG_BUTTON_MULTIPLE_PLACEHOLDERS" = "View Bag %@ %@";
            """)

        let rule = JSONCommentRule()
        rule.processFile(file)

        XCTAssertEqual(rule.violations.count, 0)
    }

    func testStringWithMissingDescriptionInComment() {

        let file = File(name: "Localizable.strings", content: """
            /*
              Retailer.strings
              Retailer

              Created by Raissa Nucci on 07/04/20.
              Copyright © 2020 Faire Inc. All rights reserved.
            */
            /*
            {
              "placeholders": ["person_name", "number"]
            }
             */
            "EMPTY_STATE.VIEW_BAG_BUTTON_MULTIPLE_PLACEHOLDERS" = "View Bag %@ %@";
            """)

        let rule = JSONCommentRule()
        rule.processFile(file)

        XCTAssertEqual(rule.violations.count, 1)
        XCTAssertEqual(rule.violations.first?.severity, .warning)
    }

    func testStringWithEmptyDescriptionInComment() {

        let file = File(name: "Localizable.strings", content: """
            /*
              Retailer.strings
              Retailer

              Created by Raissa Nucci on 07/04/20.
              Copyright © 2020 Faire Inc. All rights reserved.
            */
            /*
            {
              "description": "",
              "placeholders": ["person_name", "number"]
            }
             */
            "EMPTY_STATE.VIEW_BAG_BUTTON_MULTIPLE_PLACEHOLDERS" = "View Bag %@ %@";
            """)

        let rule = JSONCommentRule()
        rule.processFile(file)

        XCTAssertEqual(rule.violations.count, 1)
        XCTAssertEqual(rule.violations.first?.severity, .warning)
    }

    func testStringWithInvalidPlaceholdersInComment() {

        let file = File(name: "Localizable.strings", content: """
            /*
              Retailer.strings
              Retailer

              Created by Raissa Nucci on 07/04/20.
              Copyright © 2020 Faire Inc. All rights reserved.
            */
            /*
            {
              "description": "A CTA to go to the New Arrivals shopping section, links the retailer to this category",
              "placeholders": ["person_name", "asdf"]
            }
             */
            "EMPTY_STATE.VIEW_BAG_BUTTON_MULTIPLE_PLACEHOLDERS" = "View Bag %@ %@";
            """)

        let rule = JSONCommentRule()
        rule.processFile(file)

        XCTAssertEqual(rule.violations.count, 1)
        XCTAssertEqual(rule.violations.first?.severity, .warning)
    }

    func testStringWithPlaceholderCountNotMatchingInComment() {

        let file = File(name: "Localizable.strings", content: """
            /*
              Retailer.strings
              Retailer

              Created by Raissa Nucci on 07/04/20.
              Copyright © 2020 Faire Inc. All rights reserved.
            */
            /*
            {
              "description": "A CTA to go to the New Arrivals shopping section, links the retailer to this category",
              "placeholders": ["person_name"]
            }
             */
            "EMPTY_STATE.VIEW_BAG_BUTTON_MULTIPLE_PLACEHOLDERS" = "View Bag %@ %@";
            """)

        let rule = JSONCommentRule()
        rule.processFile(file)

        XCTAssertEqual(rule.violations.count, 1)
        XCTAssertEqual(rule.violations.first?.severity, .warning)
    }

    func testStringWithInvalidComment() {

        let file = File(name: "Localizable.strings", content: """
            /*
              Retailer.strings
              Retailer

              Created by Raissa Nucci on 07/04/20.
              Copyright © 2020 Faire Inc. All rights reserved.
            */
            /*
            {
              "description": "A CTA to go to the New Arrivals shopping section, links the retailer to this category",
             */
            "EMPTY_STATE.VIEW_BAG_BUTTON_MULTIPLE_PLACEHOLDERS" = "View Bag %@ %@";
            """)

        let rule = JSONCommentRule()
        rule.processFile(file)

        XCTAssertEqual(rule.violations.count, 1)
        XCTAssertEqual(rule.violations.first?.severity, .warning)
    }

  func testStringWithValidComment_NewlyAddedPlaceholderTypes() {

      let file = File(name: "Localizable.strings", content: """
          /*
            Retailer.strings
            Retailer

            Created by Raissa Nucci on 07/04/20.
            Copyright © 2020 Faire Inc. All rights reserved.
          */
          /*
          {
            "description": "A CTA to go to the New Arrivals shopping section, links the retailer to this category",
            "placeholders": ["tariff_code", "sku", "token", "tracking_code"]
          }
           */
          "EMPTY_STATE.VIEW_BAG_BUTTON_MULTIPLE_PLACEHOLDERS" = "View Bag %@ %@ %@ %@";
          """)

      let rule = JSONCommentRule()
      rule.processFile(file)

      XCTAssertEqual(rule.violations.count, 0)
  }

}
