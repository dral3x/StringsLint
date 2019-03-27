//
//  StringsdictParserTests.swift
//  StringsLintFrameworkTests
//
//  Created by Alessandro "Sandro" Calzavara on 27/03/2019.
//

import XCTest
@testable import StringsLintFramework

class StringsdictParserTests: ParserTestCase {

    func testParseFullFile() throws {
        let content = """
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>things_count</key>
        <dict>
            <key>NSStringLocalizedFormatKey</key>
            <string>%#@format@</string>
            <key>format</key>
            <dict>
                <key>NSStringFormatSpecTypeKey</key>
                <string>NSStringPluralRuleType</string>
                <key>NSStringFormatValueTypeKey</key>
                <string>li</string>
                <key>one</key>
                <string>%li thing</string>
                <key>other</key>
                <string>%li things</string>
            </dict>
        </dict>
        <key>people_count</key>
        <dict>
            <key>NSStringLocalizedFormatKey</key>
            <string>%#@format@</string>
            <key>format</key>
            <dict>
                <key>NSStringFormatSpecTypeKey</key>
                <string>NSStringPluralRuleType</string>
                <key>NSStringFormatValueTypeKey</key>
                <string>li</string>
                <key>one</key>
                <string>%li person</string>
                <key>other</key>
                <string>%li people</string>
            </dict>
        </dict>
    </dict>
</plist>
"""
        
        let file = try self.createTempFile("Localizable.stringsdict", with: content, path: "/Base.lproj")
        
        let parser = StringsdictParser()
        let results = try parser.parse(file: file)
        
        XCTAssertEqual(results.count, 2)
        
        XCTAssertEqual(results[0].key, "people_count")
        XCTAssertEqual(results[0].table, "Localizable")
        XCTAssertEqual(results[0].locale, .base)
        XCTAssertEqual(results[0].location, Location(file: file, line: 21))
        
        XCTAssertEqual(results[1].key, "things_count")
        XCTAssertEqual(results[1].table, "Localizable")
        XCTAssertEqual(results[1].locale, .base)
        XCTAssertEqual(results[1].location, Location(file: file, line: 5))
    }

    func testParseOtherStringsFileInIT() throws {
        
        let content = """
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>things_count</key>
        <dict>
            <key>NSStringLocalizedFormatKey</key>
            <string>%#@format@</string>
            <key>format</key>
            <dict>
                <key>NSStringFormatSpecTypeKey</key>
                <string>NSStringPluralRuleType</string>
                <key>NSStringFormatValueTypeKey</key>
                <string>li</string>
                <key>one</key>
                <string>%li thing</string>
                <key>other</key>
                <string>%li things</string>
            </dict>
        </dict>
    </dict>
</plist>
"""
        
        let file = try self.createTempFile("Other.stringsdict", with: content, path: "/it.lproj")
        
        let parser = StringsdictParser()
        let results = try parser.parse(file: file)
        
        XCTAssertEqual(results.count, 1)
        
        XCTAssertEqual(results[0].key, "things_count")
        XCTAssertEqual(results[0].table, "Other")
        XCTAssertEqual(results[0].locale, .language("it"))
        XCTAssertEqual(results[0].location, Location(file: file, line: 5))
    }
}
