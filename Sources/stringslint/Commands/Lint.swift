//
//  Lint.swift
//  StringsLint
//
//  Created by Alessandro Calzavara on 30/09/24.
//

import ArgumentParser
import StringsLintFramework

@main
extension StringsLint {
    struct Lint: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Print lint warnings and errors (default command)")

        @Option(help: "The path to the file or directory to lint.")
        var path: String?
        @Argument(help: "List of paths to the files or directories to lint.")
        var paths = [String]()
        @Option(help: "The path to StringsLint's configuration file.")
        var config: String = Configuration.fileName

        func run() throws {

            let allPaths: [String]
            if let path {
                allPaths = [path]
            } else if !paths.isEmpty {
                allPaths = paths
            } else {
                allPaths = [""] // Lint files in current working directory if no paths were specified.
            }
            let options = LintOptions(paths: allPaths, configurationFile: config)

            // Setup
            let configuration = Configuration(options: options)
            let files = configuration.lintableFiles(options: options)

            // Process all files
            let result = linterFrom(configuration: configuration).lintFiles(files)
                .map { $0.filter { $0.severity != .none } }
                .map { violations -> [Violation] in

                    // Report violations
                    let reporter = reporterFrom(identifier: XcodeReporter.identifier)
                    reporter.report(violations: violations)

                    return violations
                }
                .map { violations -> Result<[Violation], StringsLintError> in

                    let numberOfSeriousViolations = violations.filter({ $0.severity == .error }).count

                    printStatus(violations: violations, files: files, serious: numberOfSeriousViolations)

                    if numberOfSeriousViolations > 0 {
                        return .failure(StringsLintError.usageError(description: "A serious violation has been found"))
                    }
                    return .success(violations)
            }

            switch result {
            case .success:
                return
            case .failure(let error):
                throw error
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
}

struct LintOptions {
    let paths: [String]
    let configurationFile: String
}
