//
//  Locale.swift
//  StringsLintFramework
//
//  Created by Alessandro "Sandro" Calzavara on 11/09/2018.
//

import Foundation

enum Locale {
    case none
    case base
    case language(String)
    
    var isBase: Bool {
        if case .base = self {
            return true
        }
        return false
    }
    
    var isNone: Bool {
        if case .none = self {
            return true
        }
        return false
    }
}

extension Locale {
    
    init(url: URL?) {
        if let localeComponent = url?.pathComponents.dropLast().last , localeComponent.hasSuffix(".lproj") {
            let lang = localeComponent.replacingOccurrences(of: ".lproj", with: "")
            
            if lang == "Base" {
                self = .base
            }
            else {
                self = .language(lang)
            }
        }
        else {
            self = .none
        }
    }
    
    var localeDescription: String? {
        switch self {
        case .none:
            return nil
            
        case .base:
            return "Base"
            
        case .language(let language):
            return language
        }
    }
}

extension Locale: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .none:
            return "none"
            
        case .base:
            return "base"
            
        case .language(let language):
            return language
        }
    }
}

extension Locale: Hashable {
    var hashValue: Int {
        switch self {
        case .none:
            return 0
            
        case .base:
            return 1
            
        case .language(let language):
            return 2 &+ language.hashValue
        }
    }
}

func == (lhs: Locale, rhs: Locale) -> Bool {
    switch (lhs, rhs) {
    case (.none, .none):
        return true
        
    case (.base, .base):
        return true
        
    case let (.language(lLang), .language(rLang)):
        return lLang == rLang
        
    default:
        return false
    }
}
