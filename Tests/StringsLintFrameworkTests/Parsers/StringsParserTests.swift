//
//  StringsParserTests.swift
//  StringsLintFrameworkTests
//
//  Created by Alessandro "Sandro" Calzavara on 23/09/2018.
//

import XCTest
@testable import StringsLintFramework

class StringsParserTests: ParserTestCase {

    func testParseFullFile() throws {
        
        let content = """
/*
  LocalizedStrings.strings
  StringsLint

  Created by Alessandro "Sandro" Calzavara on 23/09/2018.
*/

/* Engineer comment 1 */
"text_1" = "Text Example 1";

/* Engineer comment 2 */
"text_2" = "Text Example 2";

"""
        
        let file = try self.createTempFile("Localizable.strings", with: content, path: "/Base.lproj")
        
        let parser = StringsParser()
        let results = try parser.parse(file: file)
        
        XCTAssertEqual(results.count, 2)
        
        XCTAssertEqual(results[0].key, "text_1")
        XCTAssertEqual(results[0].table, "Localizable")
        XCTAssertEqual(results[0].locale, .base)
        XCTAssertEqual(results[0].location, Location(file: file, line: 9))
        
        XCTAssertEqual(results[1].key, "text_2")
        XCTAssertEqual(results[1].table, "Localizable")
        XCTAssertEqual(results[1].locale, .base)
        XCTAssertEqual(results[1].location, Location(file: file, line: 12))
    }
    
    func testParseBaseLocalizableStringsFile() throws {
        
        let content = """
/* Engineer comment 1 */
"text_1" = "Text Example 1";
"""
        
        let file = try self.createTempFile("Localizable.strings", with: content, path: "/Base.lproj")
        
        let parser = StringsParser()
        let results = try parser.parse(file: file)
        
        XCTAssertEqual(results.count, 1)
        
        XCTAssertEqual(results[0].key, "text_1")
        XCTAssertEqual(results[0].table, "Localizable")
        XCTAssertEqual(results[0].locale, .base)
        XCTAssertEqual(results[0].location, Location(file: file, line: 2))
    }
    
    func testParseLocalizableStringsFileInEn() throws {
        
        let content = """
/* Engineer comment 1 */
"text_1" = "Text Example 1";
"""
        
        let file = try self.createTempFile("Localizable.strings", with: content, path: "/en.lproj")
        
        let parser = StringsParser()
        let results = try parser.parse(file: file)
        
        XCTAssertEqual(results.count, 1)
        
        XCTAssertEqual(results[0].key, "text_1")
        XCTAssertEqual(results[0].table, "Localizable")
        XCTAssertEqual(results[0].locale, .language("en"))
        XCTAssertEqual(results[0].location, Location(file: file, line: 2))
    }
    
    func testParseOtherStringsFileInIT() throws {
        
        let content = """
/* Engineer comment 1 */
"text_1" = "Text Example 1";
"""
        
        let file = try self.createTempFile("Other.strings", with: content, path: "/it.lproj")
        
        let parser = StringsParser()
        let results = try parser.parse(file: file)
        
        XCTAssertEqual(results.count, 1)
        
        XCTAssertEqual(results[0].key, "text_1")
        XCTAssertEqual(results[0].table, "Other")
        XCTAssertEqual(results[0].locale, .language("it"))
        XCTAssertEqual(results[0].location, Location(file: file, line: 2))
    }

}
