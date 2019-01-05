//
//  Location.swift
//  StringsLintFramework
//
//  Created by Alessandro "Sandro" Calzavara on 11/09/2018.
//

import Foundation

public struct Location: CustomStringConvertible, Comparable {
    public let file: File?
    public let line: Int?
    public let character: Int?

    public var description: String {
        // Xcode likes warnings and errors in the following format:
        // {full_path_to_file}{:line}{:character}: {error,warning}: {content}
        let fileString: String = file?.path ?? "<nopath>"
        let lineString: String = ":\(line ?? 1)"
        let charString: String = character.map({ ":\($0)" }) ?? ""
        return [fileString, lineString, charString].joined()
    }
    
    public init(file: File?, line: Int? = nil, character: Int? = nil) {
        self.file = file
        self.line = line
        self.character = character
    }
}

// MARK: Comparable
private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (lhs?, rhs?):
        return lhs < rhs
    case (nil, _?):
        return true
    default:
        return false
    }
}

public func == (lhs: Location, rhs: Location) -> Bool {
    return lhs.file == rhs.file &&
        lhs.line == rhs.line &&
        lhs.character == rhs.character
}

public func < (lhs: Location, rhs: Location) -> Bool {
    if lhs.file != rhs.file {
        return lhs.file < rhs.file
    }
    if lhs.line != rhs.line {
        return lhs.line < rhs.line
    }
    return lhs.character < rhs.character
}
