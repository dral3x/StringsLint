//
//  PartialRuleConfigurationTests.swift
//  StringsLintFrameworkTests
//
//  Created by Alessandro "Sandro" Calzavara on 10/01/2019.
//

import XCTest
@testable import StringsLintFramework

class PartialRuleConfigurationTests: ConfigurationTestCase {

    func testSeverity() throws {
        
        let content = """
severity: none
"""
        
        let data = try self.creareConfigFileAsDictionary(with: content)
        
        var configuration = PartialRuleConfiguration()
        
        // Default value
        XCTAssertEqual(configuration.severity, .warning)
        
        // Apply new value
        try configuration.apply(data)
        
        XCTAssertEqual(configuration.severity, .none)
    }

}
