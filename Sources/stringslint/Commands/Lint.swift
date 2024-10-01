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

            switch try execute(with: options) {
            case .success:
                throw ExitCode.success
            case .failure:
                throw ExitCode(2)
            }
        }

        private func execute(with options: LintOptions) throws -> Result<[Violation], StringsLintError> {
            // Setup
            let configuration = Configuration(options: options)
            let files = configuration.lintableFiles(options: options)

            // Process all files
            let result = linterFrom(configuration: configuration).lintFiles(files)
                .map { $0.filter { $0.severity != .none } }
            if case .failure(let error) = result {
                return .failure(error)
            }

            let violations = try result.get()

            // Report violations
            let reporter = reporterFrom(identifier: XcodeReporter.identifier)
            reporter.report(violations: violations)

            // Report exit code
            let numberOfSeriousViolations = violations.filter { $0.severity == .error }.count

            printStatus(violations: violations, files: files, serious: numberOfSeriousViolations)

            return numberOfSeriousViolations == 0 ? .success(violations) : .failure(StringsLintError.usageError(description: "A serious violation has been found"))
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
