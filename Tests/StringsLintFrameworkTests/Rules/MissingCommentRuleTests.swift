//
//  MissingCommentRuleTests.swift
//  StringsLintFrameworkTests
//
//  Created by Alessandro "Sandro" Calzavara on 31/08/21.
//

import XCTest
@testable import StringsLintFramework

class MissingCommentRuleTests: XCTestCase {

    func testStringWithComment() {
        
        let file = File(name: "Localizable.strings", content: """
            /* This is a simple comment */
            \"abc\" = \"A B C\";
            """)
        
        let rule = MissingCommentRule()
        rule.processFile(file)
        
        XCTAssertEqual(rule.violations.count, 0)
    }
    
    func testStringWithoutComment() {
        
        let file = File(name: "Localizable.strings", content: """
            \"abc\" = \"A B C\";
            """)
        
        let rule = MissingCommentRule()
        rule.processFile(file)
        
        XCTAssertEqual(rule.violations.count, 1)
        XCTAssertEqual(rule.violations[0].severity, .warning)
    }

}
