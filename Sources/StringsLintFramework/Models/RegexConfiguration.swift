//
//  CustomRegex.swift
//
//
//  Created by Jalal Awqati on 18/02/2024.
//

import Foundation

public struct CustomRegex {

    private enum Key: String {
        case pattern
        case matchIndex = "match_index"
    }

    let pattern: String
    let matchIndex: Int

    init(pattern: String, matchIndex: Int) {
        self.pattern = pattern
        self.matchIndex = matchIndex
    }

    init?(config: Any?) {
        if let config = config,
           let pattern = defaultDictionaryValue(config, for: Key.pattern.rawValue) as? String,
           let matchIndex = defaultDictionaryValue(config, for: Key.matchIndex.rawValue) as? Int {
            self.pattern = pattern
            self.matchIndex = matchIndex
        } else {
            return nil
        }
    }
}
