//
//  ParserConfigurationTestCase.swift
//  StringsLintFrameworkTests
//
//  Created by Alessandro "Sandro" Calzavara on 10/01/2019.
//

import XCTest
@testable import StringsLintFramework

class ParserConfigurationTestCase: ConfigurationTestCase {

    func creareConfigFileAsDictionary(with content: String) throws -> Any {
        
        let file = try self.createTempConfigurationFile(with: content)
        
        let yamlContents = try String(contentsOfFile: file, encoding: .utf8)
        let dict = try YamlParser.parse(yamlContents)
        
        return dict as Any
    }

}
