//
//  Array+StringsLint.swift
//  StringsLintFramework
//
//  Created by Alessandro "Sandro" Calzavara on 11/09/2018.
//

import Dispatch
import Foundation

extension Array {
    
    static func array(of obj: Any?) -> [Element]? {
        if let array = obj as? [Element] {
            return array
        } else if let obj = obj as? Element {
            return [obj]
        }
        return nil
    }
    
    // Safely lookup an index that might be out of bounds,
    // returning nil if it does not exist
    public func get(_ index: Int) -> Element? {
        
        if 0 <= index && index < count {
            return self[index]
        } else {
            return nil
        }
    }
}

extension Array where Element: Hashable {
    
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.subtracting(otherSet))
    }
}
