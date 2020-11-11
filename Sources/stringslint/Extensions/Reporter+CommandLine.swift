//
//  Reporter+CommandLine.swift
//  stringslint
//
//  Created by Alessandro "Sandro" Calzavara on 11/09/2018.
//

import StringsLintFramework

extension Reporter {
    static func report(violations: [Violation]) {
        let report = generateReport(violations)
        if !report.isEmpty {
            queuedPrint(report)
        }
    }
}
