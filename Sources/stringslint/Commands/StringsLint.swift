//
//  StringsLint.swift
//  StringsLint
//
//  Created by Alessandro Calzavara on 30/09/24.
//

import ArgumentParser
import Foundation
import StringsLintFramework

struct StringsLint: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "stringslint",
        abstract: "A tool to enforce Swift style and conventions.",
        version: Version.value,
        subcommands: [
            Lint.self,
            Version.self
        ],
        defaultSubcommand: Lint.self
    )
}
