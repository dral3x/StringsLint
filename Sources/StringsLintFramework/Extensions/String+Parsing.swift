//
//  String+Parsing.swift
//  
//
//  Created by Mark Hall on 2022-07-19.
//

import Foundation

extension String {    
    func matchFirst(regex: String) -> String? {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            if let result = regex.firstMatch(in: self, range: NSRange(self.startIndex..., in: self)) {
                return String(self[Range(result.range(at: 1), in: self)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
        }
        return nil
    }

    func matchFirstSafe(regex: String) -> String? {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            if let result = regex.firstMatch(in: self, range: NSRange(self.startIndex..., in: self)) {
                return String(self[Range(result.range, in: self)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
        }
        return nil
    }

    func matchAll(regex: String) -> [String]? {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
        }
        return nil
    }

    /// Finds comments in the format of `//` or `/* */` or multi-line comments surrounded by `/* */`
    var comment: String? {
        return self.matchFirstSafe(regex: "(\\/\\*(.|\n)*?\\*\\/)|(\\/[^\n]*|\\/\\*[\\s\\S]*?\\*\\/)")
    }

    var localizedKey: String? {
        return self.matchFirst(regex: "\"(?<key>.*)\" = \"(.*)\"")
    }
}
