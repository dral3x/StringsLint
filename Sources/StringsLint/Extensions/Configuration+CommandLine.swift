//
//  Configuration+CommandLine.swift
//  stringslint
//
//  Created by Alessandro "Sandro" Calzavara on 11/09/2018.
//

import Foundation
import StringsLintFramework

extension Configuration {
    
    func lintableFiles(options: LintOptions) -> [String] {
        return options.paths.flatMap { self.lintableFiles(inPath: $0) }
    }
    
    internal func lintableFiles(inPath path: String, fileManager: LintableFileManager = FileManager.default) -> [String] {
        if path.isFile {
            return [path]
        }
        
        let pathsForPath = self.included.isEmpty ? fileManager.filesToLint(inPath: path, rootDirectory: nil) : []
        let excludedPaths = self.excluded
            .flatMap { Glob.resolveGlob($0) }
            .flatMap {
                fileManager.filesToLint(inPath: $0, rootDirectory: rootPath)
            }
        let includedPaths = self.included.flatMap {
            fileManager.filesToLint(inPath: $0, rootDirectory: self.rootPath)
        }
        return (pathsForPath + includedPaths).filter {
            !excludedPaths.contains($0)
        }
    }
    
    // MARK: - Lint Command
    
    init(options: LintOptions) {
        self.init(path: options.configurationFile, rootPath: type(of: self).rootPath(from: options.paths), optional: isConfigOptional())
    }
    
    private static func rootPath(from paths: [String]) -> String? {
        // We don't know the root when more than one path is passed (i.e. not useful if the root of 2 paths is ~)
        return paths.count == 1 ? paths.first?.absolutePathStandardized() : nil
    }
    
}

private func isConfigOptional() -> Bool {
    return !CommandLine.arguments.contains("--config")
}
