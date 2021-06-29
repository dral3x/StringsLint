//
//  LocalizedString.swift
//  stringslint
//
//  Created by Alessandro "Sandro" Calzavara on 11/09/2018.
//

public struct LocalizedString: CustomStringConvertible, Hashable {
    let key: String
    let table: String
    let locale: Locale
    let location: Location
    var comment: String? = nil
    
    public var description: String {
        return [
            "table: \(self.table)",
            "key: \(self.key)",
            "locale: \(self.locale)",
        ].joined(separator: ", ")
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(key)
        hasher.combine(table)
    }
}

// MARK: Equatable
public func == (lhs: LocalizedString, rhs: LocalizedString) -> Bool {
    return (lhs.key == rhs.key) && (lhs.table == rhs.table)
}
