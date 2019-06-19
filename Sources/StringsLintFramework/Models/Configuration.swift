//
//  Configuration.swift
//  StringsLintFramework
//
//  Created by Alessandro "Sandro" Calzavara on 11/09/2018.
//

import Foundation

public struct Configuration: Hashable {
    
    // MARK: Properties
    public static let fileName = ".stringslint.yml"

    public let included: [String]                      // included
    public let excluded: [String]                      // excluded
    public private(set) var rootPath: String?          // the root path to search for nested configurations
    public private(set) var configurationPath: String? // if successfully loaded from a path
    
    public func hash(into hasher: inout Hasher) {
        if let configurationPath = configurationPath {
            hasher.combine(configurationPath)
        } else if let rootPath = rootPath {
            hasher.combine(rootPath)
        } else {
            hasher.combine(included)
            hasher.combine(excluded)
        }
    }
    
    // MARK: Rules Properties
    public let rules: [LintRule]
    
    // MARK: Initializers
    public init(included: [String] = [],
                 excluded: [String] = [],
                 ruleList: RuleList = masterRuleList,
                 rules: [LintRule]?) {
        
        let configuredRules = rules
            ?? (try? ruleList.configuredRules(with: [:]))
            ?? []
        
        self.init(included: included,
                  excluded: excluded,
                  rules: configuredRules,
                  rootPath: nil)
    }
    
    internal init(included: [String],
                  excluded: [String],
                  rules: [LintRule],
                  rootPath: String? = nil) {
        
        self.included = included
        self.excluded = excluded
        self.rules = rules
        self.rootPath = rootPath
    }
    
    private init(_ configuration: Configuration) {
        included = configuration.included
        excluded = configuration.excluded
        rules = configuration.rules
        rootPath = configuration.rootPath
    }
    
    public init(path: String = Configuration.fileName, rootPath: String? = nil, optional: Bool = true, quiet: Bool = false) {
        
        let fullPath: String
        if let rootPath = rootPath, rootPath.isDirectory() {
            fullPath = path.bridge().absolutePathRepresentation(rootDirectory: rootPath)
        } else {
            fullPath = path.bridge().absolutePathRepresentation()
        }
        
        let fail = { (msg: String) in
            queuedPrintError("\(fullPath):\(msg)")
            queuedFatalError("Could not read configuration file at path '\(fullPath)'")
        }
        if path.isEmpty || !FileManager.default.fileExists(atPath: fullPath) {
            if !optional { fail("File not found.") }
            self.init(rules: nil)
            self.rootPath = rootPath
            return
        }
        do {
            let yamlContents = try String(contentsOfFile: fullPath, encoding: .utf8)
            let dict = try YamlParser.parse(yamlContents)
            if !quiet {
                queuedPrintError("Loading configuration from '\(path)'")
            }
            self.init(dict: dict)!
            configurationPath = fullPath
            self.rootPath = rootPath
            return
        } catch YamlParserError.yamlParsing(let message) {
            fail(message)
        } catch {
            fail("\(error)")
        }
        self.init(rules: nil)
    }
}

// MARK: Equatable
public func == (lhs: Configuration, rhs: Configuration) -> Bool {
    return (lhs.rootPath == rhs.rootPath) &&
        (lhs.configurationPath == rhs.configurationPath) &&
        (lhs.included == rhs.included) &&
        (lhs.excluded == rhs.excluded)
}
