//
//  String+Range.swift
//  StringsLintFrameworkTests
//
//  Created by Alessandro "Sandro" Calzavara on 22/09/2020.
//

import Foundation

public extension String {
    
    func split(by result: NSTextCheckingResult) -> [String] {
        var segments = [String]()
        
        for rangeIndex in 0..<result.numberOfRanges {
            if let range = Range<Index>(result.range(at: rangeIndex), in: self) {
                let safeRange = range.clamped(to: self.startIndex..<self.endIndex)
                let substring = self[safeRange.lowerBound..<safeRange.upperBound]
                segments.append(String(substring))
            }
        }
        
        return segments
    }

}
