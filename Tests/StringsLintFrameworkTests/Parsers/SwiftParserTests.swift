//
//  SwiftParserTests.swift
//  StringsLintFrameworkTests
//
//  Created by Alessandro "Sandro" Calzavara on 12/09/2018.
//

import XCTest
@testable import StringsLintFramework

class SwiftParserTests: ParserTestCase {
    
    func testParseSingleString() throws {
        
        let content = """
NSLocalizedString(\"abc\", comment: \"blabla\")
"""
        
        let file = try self.createTempFile("test1.swift", with: content)
        
        let parser = SwiftParser()
        let results = try parser.parse(file: file)
        
        XCTAssertEqual(results.count, 1)
        
        XCTAssertEqual(results[0].key, "abc")
        XCTAssertEqual(results[0].table, "Localizable")
        XCTAssertEqual(results[0].locale, .none)
        XCTAssertEqual(results[0].location, Location(file: file, line: 1))
    }
    
    func testParseMultipleStringsOnMultipleLines() throws {
        
        let content = """
NSLocalizedString(\"abc\", comment: \"blabla\")
NSLocalizedString(\"def\", tableName: \"ttt\", comment: \"blabla\")
"""
        
        let file = try self.createTempFile("test2.swift", with: content)
        
        let parser = SwiftParser()
        let results = try parser.parse(file: file)
        
        XCTAssertEqual(results.count, 2)
        
        XCTAssertEqual(results[0].key, "abc")
        XCTAssertEqual(results[0].table, "Localizable")
        XCTAssertEqual(results[0].locale, .none)
        XCTAssertEqual(results[0].location, Location(file: file, line: 1))
        
        XCTAssertEqual(results[1].key, "def")
        XCTAssertEqual(results[1].table, "ttt")
        XCTAssertEqual(results[1].locale, .none)
        XCTAssertEqual(results[1].location, Location(file: file, line: 2))
    }
    
    func testParseSingleStringWithTable() throws {
        
        let content = """
NSLocalizedString(\"abc\", tableName: \"ttt\", comment: \"blabla\")
"""
        
        let file = try self.createTempFile("test3.swift", with: content)
        
        let parser = SwiftParser()
        let results = try parser.parse(file: file)
        
        XCTAssertEqual(results.count, 1)
        
        XCTAssertEqual(results[0].key, "abc")
        XCTAssertEqual(results[0].table, "ttt")
        XCTAssertEqual(results[0].locale, .none)
        XCTAssertEqual(results[0].location, Location(file: file, line: 1))
    }
    
    func testParseMultipleStringsOnSingleLine() throws {
        
        let content = """
NSLocalizedString(\"abc\", comment: \"blabla\") NSLocalizedString(\"def\", comment: \"blabla\")
"""
        
        let file = try self.createTempFile("test2.swift", with: content)
        
        let parser = SwiftParser()
        let results = try parser.parse(file: file)
        
        XCTAssertEqual(results.count, 2)
        
        XCTAssertEqual(results[0].key, "abc")
        XCTAssertEqual(results[0].table, "Localizable")
        XCTAssertEqual(results[0].locale, .none)
        XCTAssertEqual(results[0].location, Location(file: file, line: 1))
        
        XCTAssertEqual(results[1].key, "def")
        XCTAssertEqual(results[1].table, "Localizable")
        XCTAssertEqual(results[1].locale, .none)
        XCTAssertEqual(results[1].location, Location(file: file, line: 1))
    }
    
    func testParseCustomString() throws {
        
        let content = """
ABCLocalizedString(\"abc\", comment: \"blabla\")
ABCLocalizedString(\"abc\", tableName: \"Extras\", comment: \"blabla\")
"""
        
        let file = try self.createTempFile("test1.swift", with: content)
        
        let parser = SwiftParser(macros: [ "ABCLocalizedString" ])
        let results = try parser.parse(file: file)
        
        XCTAssertEqual(results.count, 2)
        
        XCTAssertEqual(results[0].key, "abc")
        XCTAssertEqual(results[0].table, "Localizable")
        XCTAssertEqual(results[0].locale, .none)
        XCTAssertEqual(results[0].location, Location(file: file, line: 1))
        
        XCTAssertEqual(results[1].key, "abc")
        XCTAssertEqual(results[1].table, "Extras")
        XCTAssertEqual(results[1].locale, .none)
        XCTAssertEqual(results[1].location, Location(file: file, line: 2))
    }
}
