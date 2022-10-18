//
//  SwiftL10nParserConfiguration.swift
//  StringsLintFramework
//
//  Created by Haocen Jiang on 2022-10-17.
//

import Foundation

public struct SwiftL10nParserConfiguration {

  private enum Key: String {
    case tableName = "tableName"
  }

  public var tableName = "Retailer"

  public mutating func apply(_ configuration: Any) throws {

    guard let configuration = configuration as? [String: Any],
          let tableName = configuration[Key.tableName.rawValue] as? String else {
      throw ConfigurationError.unknownConfiguration
    }

    self.tableName = tableName
  }

}

