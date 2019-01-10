//
//  SwiftParserConfiguration.swift
//  StringsLintFramework
//
//  Created by Alessandro "Sandro" Calzavara on 10/01/2019.
//

import Foundation

public struct SwiftParserConfiguration {
    
    private enum Key: String {
        case macros = "macros"
    }
    
    public var macros: [String] = [
        "NSLocalizedString",
        "CFLocalizedString"
        ]
    
    public mutating func apply(_ configuration: Any) throws {
        
        guard let configuration = configuration as? [String: Any] else {
            throw ConfigurationError.unknownConfiguration
        }
        
        self.macros += defaultStringArray(configuration[Key.macros.rawValue])
    }
    
}
