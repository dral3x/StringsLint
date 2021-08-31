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
            .map { $0.filter { $0.severity != .none } }
            .flatMap { (violations) -> Result<([Violation]), CommandantError<()>> in
                
                // Report violations
                let reporter = reporterFrom(identifier: XcodeReporter.identifier)
                reporter.report(violations: violations)
                
                return .success(violations)
            }.flatMap { (violations) -> Result<(), CommandantError<()>> in
                
                let numberOfSeriousViolations = violations.filter({ $0.severity == .error }).count
                
                printStatus(violations: violations, files: files, serious: numberOfSeriousViolations)
                
                if numberOfSeriousViolations > 0 {
                    exit(2)
                }
                return .success(())
        }
    }
    
    private func printStatus(violations: [Violation], files: [String], serious: Int) {
        let pluralSuffix = { (collection: [Any]) -> String in
            return collection.count != 1 ? "s" : ""
        }
        queuedPrintError(
            "Done linting! Found \(violations.count) violation\(pluralSuffix(violations)), " +
            "\(serious) serious in \(files.count) file\(pluralSuffix(files))."
        )
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
