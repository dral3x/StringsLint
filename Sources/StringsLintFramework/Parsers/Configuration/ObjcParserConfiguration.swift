//
//  ObjcParserConfiguration.swift
//  StringsLintFramework
//
//  Created by Alessandro "Sandro" Calzavara on 05/01/2019.
//

import Foundation

public struct ObjcParserConfiguration {
    
    private enum Key: String {
        case implicit = "implicit_macros"
        case explicit = "explicit_macros"
    }
    
    public var implicitMacros: [String] = [
        "NSLocalizedString",
        ]
    
    public var explicitMacros: [String] = [
        "NSLocalizedStringFromTable",
        ]
    
    public mutating func apply(_ configuration: Any) throws {
        
        guard let configuration = configuration as? [String: Any] else {
            throw ConfigurationError.unknownConfiguration
        }
        
        self.implicitMacros += defaultStringArray(configuration[Key.implicit.rawValue])
        self.explicitMacros += defaultStringArray(configuration[Key.explicit.rawValue])
    }
    
}
