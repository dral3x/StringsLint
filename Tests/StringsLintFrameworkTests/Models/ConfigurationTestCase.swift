//
//  ConfigurationTestCase.swift
//  StringsLintFrameworkTests
//
//  Created by Alessandro "Sandro" Calzavara on 04/11/2018.
//

import XCTest
@testable import StringsLintFramework

class ConfigurationTestCase: XCTestCase {
    
    private var tempFiles = [URL]()
    
    func createTempConfigurationFile(with content: String, path: String? = nil) throws -> String {
        
        let directory = "\(NSTemporaryDirectory())\(path ?? "")"
        try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
        
        let url = URL(fileURLWithPath: directory).appendingPathComponent(Configuration.fileName)
        
        try Data(content.utf8).write(to: url, options: .atomic)
        
        self.tempFiles.append(url)
        
        return url.path
    }
    
    func creareConfigFileAsDictionary(with content: String) throws -> Any {
        
        let file = try self.createTempConfigurationFile(with: content)
        
        let yamlContents = try String(contentsOfFile: file, encoding: .utf8)
        let dict = try YamlParser.parse(yamlContents)
        
        return dict as Any
    }
    
    func cleanupTempFiles() {
        self.tempFiles.forEach { try? FileManager.default.removeItem(at: $0) }
        self.tempFiles.removeAll()
    }
    
    override func tearDown() {
        
        self.cleanupTempFiles()
        
        super.tearDown()
    }
}
