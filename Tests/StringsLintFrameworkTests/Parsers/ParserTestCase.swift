//
//  ParserTestCase.swift
//  StringsLintFrameworkTests
//
//  Created by Alessandro "Sandro" Calzavara on 23/09/2018.
//

import XCTest
@testable import StringsLintFramework

class ParserTestCase: XCTestCase {
    
    private var tempFiles = [URL]()
    
    func createTempFile(_ name: String, with content: String, path: String? = nil) throws -> File {
        
        let directory = "\(NSTemporaryDirectory())\(path ?? "")"
        try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
        
        let url = URL(fileURLWithPath: directory).appendingPathComponent(name)
        
        try Data(content.utf8).write(to: url, options: .atomic)
        
        self.tempFiles.append(url)
        
        return File(url: url)!
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
