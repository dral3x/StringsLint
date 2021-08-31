//
//  XcodeReporterTests.swift
//  StringsLintFrameworkTests
//
//  Created by Alessandro "Sandro" Calzavara on 31/08/21.
//

import XCTest
@testable import StringsLintFramework

class XcodeReporterTests: XCTestCase {

    private var tempFiles = [URL]()
    
    private func createTempFile(named name: String, at path: String? = nil, with content: String) throws -> String {
        
        let directory = "\(NSTemporaryDirectory())\(path ?? "")"
        try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
        
        let url = URL(fileURLWithPath: directory).appendingPathComponent(name)
        
        try Data(content.utf8).write(to: url, options: .atomic)
        
        self.tempFiles.append(url)
        
        return url.path
    }
    
    private func cleanupTempFiles() {
        self.tempFiles.forEach { try? FileManager.default.removeItem(at: $0) }
        self.tempFiles.removeAll()
    }
    
    override func tearDown() {
        self.cleanupTempFiles()
        
        super.tearDown()
    }
    
    func testGenerateReport() throws {
        // Given
        let filePath = try self.createTempFile(named: "Example.swift", at: "Sources", with: "a\nb\nc")
        let file = File(url: URL(fileURLWithPath: filePath))
        let rule = RuleDescription(identifier: "fake_rule", name: "Fake", description: "")
        let issues = [
            Violation(ruleDescription: rule, severity: .none, location: Location(file: file, line: 0, character: 1), reason: "I'm ignored"),
            Violation(ruleDescription: rule, severity: .warning, location: Location(file: file, line: 1, character: 1), reason: "I'm a warning"),
            Violation(ruleDescription: rule, severity: .error, location: Location(file: file, line: 2, character: 1), reason: "I'm an error"),
        ]
        
        // When
        let output = XcodeReporter.self.generateReport(issues)
        
        // Then
        XCTAssertEqual("""
            \(filePath):0:1: none: Fake Violation: I'm ignored (fake_rule)
            \(filePath):1:1: warning: Fake Violation: I'm a warning (fake_rule)
            \(filePath):2:1: error: Fake Violation: I'm an error (fake_rule)
            """, output)
    }
}
