//
//  SwiftParserConfigurationTests.swift
//  StringsLintFrameworkTests
//
//  Created by Alessandro "Sandro" Calzavara on 10/01/2019.
//

import XCTest
@testable import StringsLintFramework

class SwiftParserConfigurationTests: ParserConfigurationTestCase {
    
    func testImplicitMacros() throws {
        
        let content = """
macros:
- ABCString
"""
        
        let data = try self.creareConfigFileAsDictionary(with: content)
        
        var configuration = SwiftParserConfiguration()
        try configuration.apply(data)
        
        XCTAssertEqual(configuration.macros.count, 3)
        XCTAssertEqual(configuration.macros, [ "NSLocalizedString", "CFLocalizedString", "ABCString" ])
    }

}
