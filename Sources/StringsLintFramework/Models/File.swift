//
//  File.swift
//  StringsLintFramework
//
//  Created by Alessandro "Sandro" Calzavara on 12/09/2018.
//

import Dispatch
import Foundation

/// Represents a source file.
public final class File: Comparable {
    
    /// File URL. Nil if initialized directly with `File(contents:)`.
    public let url: URL?
    
    /// File path. Nil if initialized directly with `File(contents:)`.
    public var path: String? {
        return self.url?.path
    }
    
    /// File name
    public let name: String
    
    /// File contents.
    public var content: String {
        get {
            _contentsQueue.sync {
                if let url = self.url, _content == nil{
                    do {
                        _content = try String(contentsOf: url)
                    } catch let error {
                        queuedPrintError("Unable to read content of file \(url.path): \(error)")
                    }
                }
            }
            return _content!
        }
        set {
            _contentsQueue.sync {
                _content = newValue
                _linesQueue.sync {
                    _lines = nil
                }
            }
        }
    }
    
    /// File lines.
    public var lines: [String] {
        _linesQueue.sync {
            if _lines == nil {
                _lines = content.components(separatedBy: .newlines)
            }
        }
        return _lines!
    }
    
    private var _content: String?
    private var _lines: [String]?
    private let _contentsQueue = DispatchQueue(label: "com.alessandrocalzavara.stringslint.file.contents")
    private let _linesQueue = DispatchQueue(label: "com.alessandrocalzavara.stringslint.file.lines")
    
    /**
     Failable initializer by path. Fails if file contents could not be read as a UTF8 string.
     - parameter path: File path.
     */
    public init?(url: URL) {
        self.url = url
        self.name = url.lastPathComponent
        do {
            _content = try String(contentsOf: url)
        } catch let error {
            queuedPrintError("Could not read contents of `\(url)`: \(error)")
            return nil
        }
    }
    
    public init?(urlDeferringReading url: URL) {
        self.url = url
        self.name = url.lastPathComponent
    }
    
    /**
     Initializer by file contents. File path is nil.
     - parameter contents: File contents.
     */
    public init(name: String, content: String) {
        self.url = nil
        self.name = name
        _content = content
    }

}

// MARK: Comparable

public func < (lhs: File, rhs: File) -> Bool {
    if lhs.path != rhs.path {
        return (lhs.path ?? "") < (rhs.path ?? "")
    }
    if lhs.name != rhs.name {
        return lhs.name < rhs.name
    }
    return lhs.content < rhs.content
}

public func == (lhs: File, rhs: File) -> Bool {
    if let lurl = lhs.url, let rurl = rhs.url {
        return lurl == rurl
    }
    
    return lhs.content == rhs.content
}

