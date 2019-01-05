//
//  String+StringsLint.swift
//  StringsLintFramework
//
//  Created by Alessandro "Sandro" Calzavara on 11/09/2018.
//

import Foundation

extension String {
    
    public func absolutePathStandardized() -> String {
        return bridge().absolutePathRepresentation().bridge().standardizingPath
    }
    
    func isDirectory() -> Bool {
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: self, isDirectory: &isDir) {
            #if os(Linux) && !swift(>=4.1)
            return isDir
            #else
            return isDir.boolValue
            #endif
        }
        return false
    }
    
    public var isFile: Bool {
        var isDirectoryObjc: ObjCBool = false
        if FileManager.default.fileExists(atPath: self, isDirectory: &isDirectoryObjc) {
            #if os(Linux) && !swift(>=4.1)
            return !isDirectoryObjc
            #else
            return !isDirectoryObjc.boolValue
            #endif
        }
        return false
    }
    
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
}

extension NSString {
    
    /**
     Returns self represented as an absolute path.
     - parameter rootDirectory: Absolute parent path if not already an absolute path.
     */
    public func absolutePathRepresentation(rootDirectory: String = FileManager.default.currentDirectoryPath) -> String {
        if isAbsolutePath { return bridge() }
        #if os(Linux)
        return NSURL(fileURLWithPath: NSURL.fileURL(withPathComponents: [rootDirectory, bridge()])!.path).standardizingPath!.path
        #else
        return NSString.path(withComponents: [rootDirectory, bridge()]).bridge().standardizingPath
        #endif
    }
    
}
