//
//  SwiftParserConfigurationTests.swift
//  StringsLintFrameworkTests
//
//  Created by Alessandro "Sandro" Calzavara on 10/01/2019.
//

import XCTest
@testable import StringsLintFramework

class SwiftParserConfigurationTests: ConfigurationTestCase {
    
    func testImplicitMacros() throws {
        
        let content = """
macros:
- ABCString
regex:
    pattern: ^\"([^\"]+)\".localized$
    match_index: 2
"""
        
        let data = try self.creareConfigFileAsDictionary(with: content)
        
        var configuration = SwiftParserConfiguration()
        try configuration.apply(data)
        
        XCTAssertEqual(configuration.macros.count, 3)
        XCTAssertEqual(configuration.macros, [ "NSLocalizedString", "CFLocalizedString", "ABCString" ])
        XCTAssertEqual(configuration.customRegex?.pattern, "^\"([^\"]+)\".localized$")
        XCTAssertEqual(configuration.customRegex?.matchIndex, 2)
    }

}
