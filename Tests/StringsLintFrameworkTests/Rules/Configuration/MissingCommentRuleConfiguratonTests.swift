//
//  File.swift
//  
//
//  Created by Eidinger, Marco on 6/25/21.
//

import XCTest
@testable import StringsLintFramework

class MissingCommentRuleConfigurationTests: ConfigurationTestCase {

    func testSeverity() throws {

        let content = """
severity: error
"""

        let data = try self.creareConfigFileAsDictionary(with: content)

        var configuration = MissingCommentRuleConfiguration()

        // Default value
        XCTAssertEqual(configuration.severity, .warning)

        // Apply new value
        try configuration.apply(data)

        XCTAssertEqual(configuration.severity, .error)
    }

}
