//
//  Linter.swift
//  stringslint
//
//  Created by Alessandro "Sandro" Calzavara on 11/09/2018.
//

import Foundation
import Dispatch
import Commandant
import Result
import StringsLintFramework

struct Linter {
    
    let parallel: Bool
    let rules: [LintRule]
    let lintableExtentions: Set<String>
    
    init(rules: [LintRule], parallel: Bool = true) {
        self.rules = rules
        self.parallel = parallel
        self.lintableExtentions = supportedFilesExtentions()
    }
    
    func lintFiles(_ files: [String]) -> Result<[Violation], CommandantError<()>> {
        
        var violations = [Violation]()
        
        let apply = { (file: File) in
            
            if self.parallel {
                DispatchQueue.concurrentPerform(iterations: self.rules.count) { index in
                    self.rules[index].processFile(file)
                }
            } else {
                self.rules.forEach {
                    $0.processFile(file)
                }
            }
        }
        
        files.forEach { (path) in
            guard self.lintableExtentions.contains(where: path.hasSuffix) else { return }
            queuedPrint("scanning \(path)")
            if let file = File(urlDeferringReading: URL(fileURLWithPath: path)) {
                apply(file)
            }
        }

        // Collect all violations and sort them
        self.rules.forEach {
            violations.append(contentsOf: $0.violations)
        }
        violations.sort(by: { $0.location < $1.location })

        return .success(violations)
    }
    
}

func linterFrom(configuration: Configuration) -> Linter {
    return Linter(rules: configuration.rules)
}

func supportedFilesExtentions() -> Set<String> {
    // based on all the parsers implemented in the library
    let parsers: [LocalizableParser] = [ ObjcParser(), StringsParser(), SwiftParser(), XibParser() ]
    let extensions = parsers.flatMap { $0.supportedFileExtentions }
    return Set(extensions.map { ".\($0)" })
}
