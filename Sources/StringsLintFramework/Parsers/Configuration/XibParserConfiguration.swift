//
//  XibParserConfiguration.swift
//  StringsLintFramework
//
//  Created by Alessandro "Sandro" Calzavara on 05/01/2019.
//

import Foundation

public struct XibParserConfiguration {
    
    private enum Key: String {
        case keyPaths = "key_paths"
    }
    
    public var keyPaths: [String] = []
    
    public mutating func apply(_ configuration: Any) throws {
        
        guard let configuration = configuration as? [String: Any] else {
            throw ConfigurationError.unknownConfiguration
        }
        
        self.keyPaths += defaultStringArray(configuration[Key.keyPaths.rawValue])
    }
}
