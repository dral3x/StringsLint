//
//  MissingRuleConfigurationTests.swift
//  StringsLintFrameworkTests
//
//  Created by Alessandro "Sandro" Calzavara on 10/01/2019.
//

import XCTest
@testable import StringsLintFramework

class MissingRuleConfigurationTests: ConfigurationTestCase {

    func testSeverity() throws {
        
        let content = """
severity: error
"""
        
        let data = try self.creareConfigFileAsDictionary(with: content)
        
        var configuration = MissingRuleConfiguration()
        
        // Default value
        XCTAssertEqual(configuration.severity, .warning)
        
        // Apply new value
        try configuration.apply(data)
        
        XCTAssertEqual(configuration.severity, .error)
    }

    func testIgnored() throws {
        let content = """
ignored:
  - ABC
  - def
"""

        let data = try self.creareConfigFileAsDictionary(with: content)

        var configuration = MissingRuleConfiguration()

        // Default value
        XCTAssertEqual(configuration.ignored, [])

        // Apply new value
        try configuration.apply(data)

        XCTAssertEqual(configuration.ignored, ["ABC", "def"])
    }

}
