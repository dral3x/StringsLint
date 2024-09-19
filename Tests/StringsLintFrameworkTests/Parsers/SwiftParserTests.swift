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
        XCTAssertEqual(results[0].value, nil)
        XCTAssertEqual(results[0].locale, .none)
        XCTAssertEqual(results[0].location, Location(file: file, line: 1))
        
        XCTAssertEqual(results[1].key, "def")
        XCTAssertEqual(results[1].table, "ttt")
        XCTAssertEqual(results[0].value, nil)
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
        XCTAssertEqual(results[0].value, nil)
        XCTAssertEqual(results[0].locale, .none)
        XCTAssertEqual(results[0].location, Location(file: file, line: 1))
    }
    
    func testParseSingleStringWithTableAndValue() throws {

        let content = """
NSLocalizedString(\"abc\", tableName: \"ttt\", value: \"v\", comment: \"blabla\")
"""

        let file = try self.createTempFile("test3.swift", with: content)

        let parser = SwiftParser()
        let results = try parser.parse(file: file)

        XCTAssertEqual(results.count, 1)

        XCTAssertEqual(results[0].key, "abc")
        XCTAssertEqual(results[0].table, "ttt")
        XCTAssertEqual(results[0].value, "v")
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
        
        let parser = SwiftParser(macros: [ "ABCLocalizedString" ], customRegex: nil, swiftUIImplicitEnabled: true)
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

    func testParseCustomRegex() throws {
        
        let content = """
\"blabla\".localized
"""

        let file = try self.createTempFile("test1.swift", with: content)

        let customRegex = CustomRegex(pattern: "^\"([^\"]+)\".localized$", matchIndex: 1)
        let parser = SwiftParser(macros: [], customRegex: customRegex, swiftUIImplicitEnabled: true)
        let results = try parser.parse(file: file)
        
        XCTAssertEqual(results.count, 1)
        
        XCTAssertEqual(results[0].key, "blabla")
        XCTAssertEqual(results[0].table, "Localizable")
        XCTAssertEqual(results[0].locale, .none)
        XCTAssertEqual(results[0].location, Location(file: file, line: 1))
    }

    func testSwiftUITextWithImplicitString() throws {

        let content = """
Text("abc")
Button("def")
"""
        
        let file = try self.createTempFile("test1.swift", with: content)
        
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
        XCTAssertEqual(results[1].location, Location(file: file, line: 2))
    }
    
    func testSwiftUITextWithVerbatimString() throws {
            
        let content = """
Text(verbatim: "pencil")
"""
        
        let file = try self.createTempFile("test1.swift", with: content)
        
        let parser = SwiftParser()
        let results = try parser.parse(file: file)
        
        XCTAssertEqual(results.count, 0)
    }
    
    func testSwiftUITextWithTable() throws {

        let content = """
Text("abc", tableName: "First")
Text(LocalizedStringKey("def"), tableName: "Second")
Text(LocalizedStringKey("ghi"), tableName: "Third", comment: "Blabla")
"""
        
        let file = try self.createTempFile("test1.swift", with: content)
        
        let parser = SwiftParser()
        let results = try parser.parse(file: file)
        
        XCTAssertEqual(results.count, 3)

        XCTAssertEqual(results[0].key, "abc")
        XCTAssertEqual(results[0].table, "First")
        XCTAssertEqual(results[0].locale, .none)
        XCTAssertEqual(results[0].location, Location(file: file, line: 1))
        
        XCTAssertEqual(results[1].key, "def")
        XCTAssertEqual(results[1].table, "Second")
        XCTAssertEqual(results[1].locale, .none)
        XCTAssertEqual(results[1].location, Location(file: file, line: 2))

        XCTAssertEqual(results[2].key, "ghi")
        XCTAssertEqual(results[2].table, "Third")
        XCTAssertEqual(results[2].locale, .none)
        XCTAssertEqual(results[2].location, Location(file: file, line: 3))
    }

    func testSwiftUILocalizedStringKey() throws {

        let content = """
LocalizedStringKey("abc")
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

    func testIgnore() throws {

        let content = """
Text("abc")
Button("def") //stringslint:ignore
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

    func testIgnoreImplicit() throws {

        let content = """
Text("abc")
"""

        let file = try self.createTempFile("test1.swift", with: content)

        let parser = SwiftParser(macros: [], customRegex: nil, swiftUIImplicitEnabled: false)

        let results = try parser.parse(file: file)

        XCTAssertEqual(results.count, 0)
    }

    func testStringLocalized() throws {

        let content = """
String(localized: "abc")
String(localized: "def", defaultValue: "DEF")
String(localized: "ghi", table: "AnotherTable")
String(localized: "jkl", comment: "mmm")
"""

        let file = try self.createTempFile("test1.swift", with: content)

        let parser = SwiftParser(macros: [], customRegex: nil, swiftUIImplicitEnabled: false)

        let results = try parser.parse(file: file)

        XCTAssertEqual(results.count, 4)

        XCTAssertEqual(results[0].key, "abc")
        XCTAssertEqual(results[0].value, nil)
        XCTAssertEqual(results[0].table, "Localizable")
        XCTAssertEqual(results[0].locale, .none)
        XCTAssertEqual(results[0].location, Location(file: file, line: 1))

        XCTAssertEqual(results[1].key, "def")
        XCTAssertEqual(results[1].table, "Localizable")
        XCTAssertEqual(results[1].value, "DEF")
        XCTAssertEqual(results[1].locale, .none)
        XCTAssertEqual(results[1].location, Location(file: file, line: 2))

        XCTAssertEqual(results[2].key, "ghi")
        XCTAssertEqual(results[2].value, nil)
        XCTAssertEqual(results[2].table, "AnotherTable")
        XCTAssertEqual(results[2].locale, .none)
        XCTAssertEqual(results[2].location, Location(file: file, line: 3))

        XCTAssertEqual(results[3].key, "jkl")
        XCTAssertEqual(results[3].value, nil)
        XCTAssertEqual(results[3].table, "Localizable")
        XCTAssertEqual(results[3].locale, .none)
        XCTAssertEqual(results[3].location, Location(file: file, line: 4))
    }
}
