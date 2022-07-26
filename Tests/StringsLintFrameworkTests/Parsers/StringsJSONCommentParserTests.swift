//
//  StringsJSONCommentParserTests.swift
//  
//
//  Created by Mark Hall on 2022-07-19.
//

import XCTest
@testable import StringsLintFramework

class StringsJSONCommentParserTests: ParserTestCase {

    func testParseFullFile() throws {

        let content = """
// *** This file is generated, do not make changes to it. Please see our documentation for more information on our localization process: https://faire.link/l10n ***

/*
  Retailer.strings
  Retailer

  Created by Raissa Nucci on 07/04/20.
  Copyright © 2020 Faire Inc. All rights reserved.
*/

/*
{
  "description": "A CTA to go to the New Arrivals shopping section, links the retailer to this category"
}
 */
"EMPTY_STATE_SHOW_NEW_ARRIVALS_BUTTON" = "Shop New Arrivals";
/*
{
  "description": "A CTA to go to the New Arrivals shopping section, links the retailer to this category"
}
 */
"EMPTY_STATE.VIEW_NEW_ARRIVALS_BUTTON" = "View New Arrivals";
/*
{
  "description": "A CTA to go to the New Arrivals shopping section, links the retailer to this category",
  "placeholders": ["person_name"]
}
 */
"EMPTY_STATE.VIEW_BAG_BUTTON" = "View Bag %@";

/*
{
  "description": "A CTA to go to the New Arrivals shopping section, links the retailer to this category",
  "placeholders": ["person_name", "number"]
}
 */
"EMPTY_STATE.VIEW_BAG_BUTTON_MULTIPLE_PLACEHOLDERS" = "View Bag %@ %@";
"""

        let file = try self.createTempFile("Localizable.strings", with: content, path: "/Base.lproj")

        let parser = StringsJSONCommentParser()
        let results = try parser.parse(file: file)

        XCTAssertEqual(results.count, 4)

        let expectedLocalizedStrings = [
            LocalizedString(key: "EMPTY_STATE_SHOW_NEW_ARRIVALS_BUTTON",
                            table: "Localizable",
                            locale: .base,
                            location: Location(file: file, line: 16),
                            placeholders: [],
                            comment:
"""
{
  "description": "A CTA to go to the New Arrivals shopping section, links the retailer to this category"
}
"""),
            LocalizedString(key: "EMPTY_STATE.VIEW_NEW_ARRIVALS_BUTTON",
                            table: "Localizable",
                            locale: .base,
                            location: Location(file: file, line: 22),
                            placeholders: [],
                            comment:
"""
{
  "description": "A CTA to go to the New Arrivals shopping section, links the retailer to this category"
}
"""),
            LocalizedString(key: "EMPTY_STATE.VIEW_BAG_BUTTON",
                            table: "Localizable",
                            locale: .base,
                            location: Location(file: file, line: 29),
                            placeholders: [],
                            comment:
"""
{
  "description": "A CTA to go to the New Arrivals shopping section, links the retailer to this category",
  "placeholders": ["person_name"]
}
"""),
            LocalizedString(key: "EMPTY_STATE.VIEW_BAG_BUTTON_MULTIPLE_PLACEHOLDERS",
                            table: "Localizable",
                            locale: .base,
                            location: Location(file: file, line: 37),
                            placeholders: [],
                            comment:
"""
{
  "description": "A CTA to go to the New Arrivals shopping section, links the retailer to this category",
  "placeholders": ["person_name", "number"]
}
""")
        ]

        for (index, localizedString) in results.enumerated() {
            XCTAssertEqual(localizedString.key, expectedLocalizedStrings[index].key)
            XCTAssertEqual(localizedString.table, expectedLocalizedStrings[index].table)
            XCTAssertEqual(localizedString.locale, expectedLocalizedStrings[index].locale)
            XCTAssertEqual(localizedString.location, expectedLocalizedStrings[index].location)
            XCTAssertEqual(localizedString.comment, expectedLocalizedStrings[index].comment)
        }
    }
}
