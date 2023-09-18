//
//  ObjcParserTests.swift
//  StringsLintFrameworkTests
//
//  Created by Alessandro "Sandro" Calzavara on 30/10/2018.
//

import XCTest
@testable import StringsLintFramework

class ObjcParserTests: ParserTestCase {

    func testParseImplicitString() throws {
        
        let content = """
NSLocalizedString(@\"abc\", @\"blabla\")
"""
        
        let file = try self.createTempFile("test1.m", with: content)
        
        let parser = ObjcParser()
        let results = try parser.parse(file: file)
        
        XCTAssertEqual(results.count, 1)
        
        XCTAssertEqual(results.get(0)?.key, "abc")
        XCTAssertEqual(results.get(0)?.table, "Localizable")
        XCTAssertEqual(results.get(0)?.locale, Locale.none)
        XCTAssertEqual(results.get(0)?.location, Location(file: file, line: 1))
    }
    
    func testParseImplicitStringWithoutComment() throws {
        
        let content = """
NSLocalizedString(@\"abc\", nil)
"""
        
        let file = try self.createTempFile("test1.m", with: content)
        
        let parser = ObjcParser()
        let results = try parser.parse(file: file)
        
        XCTAssertEqual(results.count, 1)
        
        XCTAssertEqual(results.get(0)?.key, "abc")
        XCTAssertEqual(results.get(0)?.table, "Localizable")
        XCTAssertEqual(results.get(0)?.locale, Locale.none)
        XCTAssertEqual(results.get(0)?.location, Location(file: file, line: 1))
    }
    
    func testParseExplicitString() throws {
        
        let content = """
NSLocalizedStringFromTable(@\"abc\", @\"table\", @\"blabla\")
"""
        
        let file = try self.createTempFile("test1.m", with: content)
        
        let parser = ObjcParser()
        let results = try parser.parse(file: file)
        
        XCTAssertEqual(results.count, 1)
        
        XCTAssertEqual(results.get(0)?.key, "abc")
        XCTAssertEqual(results.get(0)?.table, "table")
        XCTAssertEqual(results.get(0)?.locale, Locale.none)
        XCTAssertEqual(results.get(0)?.location, Location(file: file, line: 1))
    }
    
    func testParseExplicitStringWithoutComment() throws {
        
        let content = """
NSLocalizedStringFromTable(@\"abc\", @\"table\", nil)
"""
        
        let file = try self.createTempFile("test1.m", with: content)
        
        let parser = ObjcParser()
        let results = try parser.parse(file: file)
        
        XCTAssertEqual(results.count, 1)
        
        XCTAssertEqual(results.get(0)?.key, "abc")
        XCTAssertEqual(results.get(0)?.table, "table")
        XCTAssertEqual(results.get(0)?.locale, Locale.none)
        XCTAssertEqual(results.get(0)?.location, Location(file: file, line: 1))
    }

    func testParseWithExtraImplicitMacro() throws {
        
        let content = """
CustomLocalizedString(@\"abc\", @\"blabla\")
"""
        
        let file = try self.createTempFile("test1.m", with: content)
        
        let parser = ObjcParser(implicitMacros: [ "CustomLocalizedString" ], explicitMacros: [])
        let results = try parser.parse(file: file)
        
        XCTAssertEqual(results.count, 1)
        
        XCTAssertEqual(results.get(0)?.key, "abc")
        XCTAssertEqual(results.get(0)?.table, "Localizable")
        XCTAssertEqual(results.get(0)?.locale, Locale.none)
        XCTAssertEqual(results.get(0)?.location, Location(file: file, line: 1))
    }
    
    func testParseWithExtraExplicitMacro() throws {
        
        let content = """
CustomLocalizedStringFromTable(@\"abc\", @\"table\", nil)
"""
        
        let file = try self.createTempFile("test1.m", with: content)
        
        let parser = ObjcParser(implicitMacros: [], explicitMacros: [ "CustomLocalizedStringFromTable" ])
        let results = try parser.parse(file: file)
        
        XCTAssertEqual(results.count, 1)
        
        XCTAssertEqual(results.get(0)?.key, "abc")
        XCTAssertEqual(results.get(0)?.table, "table")
        XCTAssertEqual(results.get(0)?.locale, Locale.none)
        XCTAssertEqual(results.get(0)?.location, Location(file: file, line: 1))
    }

    func testIgnoreLine() throws {

        let content = """
NSLocalizedString(@\"abc\", nil)
NSLocalizedString(@\"def\", nil) //stringslint:ignore
"""

        let file = try self.createTempFile("test1.m", with: content)

        let parser = ObjcParser(implicitMacros: [], explicitMacros: [])
        let results = try parser.parse(file: file)

        XCTAssertEqual(results.count, 1)

        XCTAssertEqual(results.get(0)?.key, "abc")
        XCTAssertEqual(results.get(0)?.table, "Localizable")
        XCTAssertEqual(results.get(0)?.locale, Locale.none)
        XCTAssertEqual(results.get(0)?.location, Location(file: file, line: 1))
    }

}
