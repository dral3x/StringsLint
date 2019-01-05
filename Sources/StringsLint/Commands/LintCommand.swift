//
//  LintCommand.swift
//  stringslint
//
//  Created by Alessandro "Sandro" Calzavara on 11/09/2018.
//

import Foundation
import Commandant
import Result
import StringsLintFramework

struct LintCommand: CommandProtocol {
    let verb = "lint"
    let function = "Print lint warnings and errors (default command)"
    
    func run(_ options: LintOptions) -> Result<(), CommandantError<()>> {

        // Setup
        let configuration = Configuration(options: options)
        let files = configuration.lintableFiles(options: options)

        // Process all files
        return linterFrom(configuration: configuration).lintFiles(files)
            .flatMap { (violations) -> Result<([Violation]), CommandantError<()>> in
                
                // Report violations
                let reporter = reporterFrom(identifier: XcodeReporter.identifier)
                reporter.report(violations: violations)
                
                return .success(violations)
            }.flatMap { (violations) -> Result<(), CommandantError<()>> in
                
                let numberOfSeriousViolations = violations.filter({ $0.severity == .error }).count
                if numberOfSeriousViolations > 0 {
                    exit(2)
                }
                return .success(())
        }
    }
}

struct LintOptions: OptionsProtocol {
    let paths: [String]
    let configurationFile: String
    
    static func create(_ path: String) -> (_ configurationFile: String) -> (_ paths: [String]) -> LintOptions {
        return { configurationFile in { paths in
            let allPaths: [String]
            if !path.isEmpty {
                allPaths = [path]
            } else {
                allPaths = paths
            }
            return self.init(paths: allPaths, configurationFile: configurationFile)
            }}
    }
    
    static func evaluate(_ mode: CommandMode) -> Result<LintOptions, CommandantError<CommandantError<()>>> {
        return create
            <*> mode <| pathOption(action: "lint")
            <*> mode <| configOption
            // This should go last to avoid eating other args
            <*> mode <| pathsArgument(action: "lint")
    }
}
