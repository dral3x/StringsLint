//
//  UnusedRule.swift
//  StringsLintFrameworkTests
//
//  Created by Alessandro "Sandro" Calzavara on 12/09/2018.
//

import XCTest
@testable import StringsLintFramework

class UnusedRuleTests: XCTestCase {
    
    func testUnusedExample() {
        
        let file1 = File(name: "Localizable.strings", content: "\"abc\" = \"A B C\";")
        let file2 = File(name: "main.swift", content: "NSLocalizedString(\"def\", comment:\"\")")
        
        let rule = UnusedRule()
        rule.processFile(file1)
        rule.processFile(file2)
        
        XCTAssertEqual(rule.violations.count, 1)
    }
    
    func testBalancedUse() {
        
        let file1 = File(name: "Localizable.strings", content: "\"loading\" = \"Loading...\";")
        let file2 = File(name: "main.swift", content: "NSLocalizedString(\"loading\", comment: \"\")")
        
        let rule = UnusedRule()
        rule.processFile(file1)
        rule.processFile(file2)
        
        XCTAssertEqual(rule.violations.count, 0)
    }
    
}
