//
//  Parsing.swift
//  StringsLintFramework
//
//  Created by Alessandro "Sandro" Calzavara on 04/11/2018.
//

import Foundation

func defaultStringArray(_ object: Any?) -> [String] {
    return [String].array(of: object) ?? []
}

func defaultDictionaryValue(_ dictionary: Any, for key: String) -> Any {
    guard let dictionary = dictionary as? [String: Any] else {
        return [:]
    }
    
    return dictionary[key] as Any
}

func defaultBooleanValue(_ object: Any?, `default`: Bool) -> Bool {
    object as? Bool ?? `default`
}
