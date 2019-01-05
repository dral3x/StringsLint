//
//  LocalizableParser.swift
//  StringsLintFramework
//
//  Created by Alessandro "Sandro" Calzavara on 11/09/2018.
//

import Foundation

public protocol LocalizableParser {
    static var identifier: String { get }
    
    init() // Parser need to be able to be initialized with default values
    init(configuration: Any) throws
    
    var supportedFileExtentions: [String] { get }
    func support(file: File) -> Bool
    func parse(file: File) throws -> [LocalizedString]
}
