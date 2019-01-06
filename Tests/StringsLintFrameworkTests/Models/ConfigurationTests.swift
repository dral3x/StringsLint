//
//  ConfigurationTests.swift
//  StringsLintFrameworkTests
//
//  Created by Alessandro "Sandro" Calzavara on 04/11/2018.
//

import XCTest
@testable import StringsLintFramework

class ConfigurationTests: ConfigurationTestCase {

    func testDefaultInit() throws {
        
        let configuration = Configuration()
        
        XCTAssertEqual(configuration.included.count, 0)
        XCTAssertEqual(configuration.excluded.count, 0)
        XCTAssertFalse(configuration.rules.isEmpty)
    }
    
    func testEmpty() throws {
        
        let content = """
"""
        
        let file = try self.createTempConfigurationFile(with: content)
        
        let configuration = Configuration(path: file)
        
        XCTAssertEqual(configuration.included.count, 0)
        XCTAssertEqual(configuration.excluded.count, 0)
        XCTAssertFalse(configuration.rules.isEmpty)
    }
    
    func testIncluded() throws {
        
        let content = """
included:
- Sources
"""
        
        let file = try self.createTempConfigurationFile(with: content)
        
        let configuration = Configuration(path: file)
        
        XCTAssertEqual(configuration.included.count, 1)
        XCTAssertEqual(configuration.included, [ "Sources" ])
        XCTAssertEqual(configuration.excluded.count, 0)
        XCTAssertFalse(configuration.rules.isEmpty)
    }
    
    func testExcluded() throws {
        
        let content = """
excluded:
- Pods
"""
        
        let file = try self.createTempConfigurationFile(with: content)
        
        let configuration = Configuration(path: file)
        
        XCTAssertEqual(configuration.included.count, 0)
        XCTAssertEqual(configuration.excluded.count, 1)
        XCTAssertEqual(configuration.excluded, [ "Pods" ])
        XCTAssertFalse(configuration.rules.isEmpty)
    }
}
