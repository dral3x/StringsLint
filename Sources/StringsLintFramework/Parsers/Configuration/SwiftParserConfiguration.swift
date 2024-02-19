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
        case customRegex = "regex"
    }
    
    public var macros: [String] = [
        "NSLocalizedString",
        "CFLocalizedString"
        ]

    public var customRegex: CustomRegex?

    public mutating func apply(_ configuration: Any) throws {
        
        guard let configuration = configuration as? [String: Any] else {
            throw ConfigurationError.unknownConfiguration
        }
        
        self.macros += defaultStringArray(configuration[Key.macros.rawValue])
        self.customRegex = CustomRegex(config: configuration[Key.customRegex.rawValue])
    }
    
}
