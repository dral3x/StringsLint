//
//  Version.swift
//  StringsLint
//
//  Created by Alessandro Calzavara on 30/09/24.
//

import ArgumentParser
import StringsLintFramework

extension StringsLint {
    struct Version: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Display the current version of StringsLint")

        static var value: String { StringsLintFramework.Version.current.value }

        mutating func run() throws {
            print(Self.value)
        }
    }
}
