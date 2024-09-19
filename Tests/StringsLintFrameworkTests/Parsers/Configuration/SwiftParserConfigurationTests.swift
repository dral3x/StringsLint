//
//  SwiftParserConfigurationTests.swift
//  StringsLintFrameworkTests
//
//  Created by Alessandro "Sandro" Calzavara on 10/01/2019.
//

import XCTest
@testable import StringsLintFramework

class SwiftParserConfigurationTests: ConfigurationTestCase {
    
    func testMacros() throws {
        
        let content = """
macros:
- ABCString
"""
        
        let data = try self.creareConfigFileAsDictionary(with: content)
        
        var configuration = SwiftParserConfiguration()
        
        // Default values
        XCTAssertEqual(configuration.macros.count, 2)
        XCTAssertEqual(configuration.macros, [ "NSLocalizedString", "CFLocalizedString" ])

        try configuration.apply(data)

        // Updated values
        XCTAssertEqual(configuration.macros.count, 3)
        XCTAssertEqual(configuration.macros, [ "NSLocalizedString", "CFLocalizedString", "ABCString" ])
    }

    func testRegex() throws {

        let content = """
regex:
    pattern: ^\"([^\"]+)\".localized$
    match_index: 2
"""

        let data = try self.creareConfigFileAsDictionary(with: content)

        var configuration = SwiftParserConfiguration()
        try configuration.apply(data)

        XCTAssertEqual(configuration.customRegex?.pattern, "^\"([^\"]+)\".localized$")
        XCTAssertEqual(configuration.customRegex?.matchIndex, 2)
    }

    func testIgnoreImplicit() throws {

        let content = """
swiftui_implicit: false
"""

        let data = try self.creareConfigFileAsDictionary(with: content)

        var configuration = SwiftParserConfiguration()
        XCTAssertTrue(configuration.swiftUIImplicitEnabled)

        try configuration.apply(data)

        XCTAssertFalse(configuration.swiftUIImplicitEnabled)
    }
}
