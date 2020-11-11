// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

@testable import StringsLintFrameworkTests
import XCTest

// swiftlint:disable line_length file_length

extension ConfigurationTestCase {
    static var allTests: [(String, (ConfigurationTestCase) -> () throws -> Void)] = [
    ]
}

extension ConfigurationTests {
    static var allTests: [(String, (ConfigurationTests) -> () throws -> Void)] = [
        ("testDefaultInit", testDefaultInit),
        ("testEmpty", testEmpty),
        ("testIncluded", testIncluded),
        ("testExcluded", testExcluded)
    ]
}

extension MissingRuleConfigurationTests {
    static var allTests: [(String, (MissingRuleConfigurationTests) -> () throws -> Void)] = [
        ("testSeverity", testSeverity)
    ]
}

extension ObjcParserConfigurationTests {
    static var allTests: [(String, (ObjcParserConfigurationTests) -> () throws -> Void)] = [
        ("testImplicitMacros", testImplicitMacros),
        ("testExplicitMacros", testExplicitMacros)
    ]
}

extension ObjcParserTests {
    static var allTests: [(String, (ObjcParserTests) -> () throws -> Void)] = [
        ("testParseImplicitString", testParseImplicitString),
        ("testParseImplicitStringWithoutComment", testParseImplicitStringWithoutComment),
        ("testParseExplicitString", testParseExplicitString),
        ("testParseExplicitStringWithoutComment", testParseExplicitStringWithoutComment),
        ("testParseWithExtraImplicitMacro", testParseWithExtraImplicitMacro),
        ("testParseWithExtraExplicitMacro", testParseWithExtraExplicitMacro)
    ]
}

extension ParserTestCase {
    static var allTests: [(String, (ParserTestCase) -> () throws -> Void)] = [
    ]
}

extension PartialRuleConfigurationTests {
    static var allTests: [(String, (PartialRuleConfigurationTests) -> () throws -> Void)] = [
        ("testSeverity", testSeverity)
    ]
}

extension StringsParserTests {
    static var allTests: [(String, (StringsParserTests) -> () throws -> Void)] = [
        ("testParseFullFile", testParseFullFile),
        ("testParseBaseLocalizableStringsFile", testParseBaseLocalizableStringsFile),
        ("testParseLocalizableStringsFileInEn", testParseLocalizableStringsFileInEn),
        ("testParseOtherStringsFileInIT", testParseOtherStringsFileInIT)
    ]
}

extension StringsdictParserTests {
    static var allTests: [(String, (StringsdictParserTests) -> () throws -> Void)] = [
        ("testParseFullFile", testParseFullFile),
        ("testParseOtherStringsFileInIT", testParseOtherStringsFileInIT)
    ]
}

extension SwiftParserConfigurationTests {
    static var allTests: [(String, (SwiftParserConfigurationTests) -> () throws -> Void)] = [
        ("testImplicitMacros", testImplicitMacros)
    ]
}

extension SwiftParserTests {
    static var allTests: [(String, (SwiftParserTests) -> () throws -> Void)] = [
        ("testParseSingleString", testParseSingleString),
        ("testParseMultipleStringsOnMultipleLines", testParseMultipleStringsOnMultipleLines),
        ("testParseSingleStringWithTable", testParseSingleStringWithTable),
        ("testParseMultipleStringsOnSingleLine", testParseMultipleStringsOnSingleLine),
        ("testParseCustomString", testParseCustomString),
        ("testSwiftUITextWithString", testSwiftUITextWithString),
        ("testSwiftUITextWithVerbatimString", testSwiftUITextWithVerbatimString),
        ("testSwiftUITextWithLocalizedStringKey", testSwiftUITextWithLocalizedStringKey)
    ]
}

extension UnusedRuleConfigurationTests {
    static var allTests: [(String, (UnusedRuleConfigurationTests) -> () throws -> Void)] = [
        ("testSeverity", testSeverity)
    ]
}

extension UnusedRuleTests {
    static var allTests: [(String, (UnusedRuleTests) -> () throws -> Void)] = [
        ("testUnusedExample", testUnusedExample),
        ("testBalancedUse", testBalancedUse),
        ("testSeverityError", testSeverityError)
    ]
}

extension XibParserTests {
    static var allTests: [(String, (XibParserTests) -> () throws -> Void)] = [
        ("testParseSingleString", testParseSingleString),
        ("testParseExampleFile", testParseExampleFile)
    ]
}

XCTMain([
    testCase(ConfigurationTestCase.allTests),
    testCase(ConfigurationTests.allTests),
    testCase(MissingRuleConfigurationTests.allTests),
    testCase(ObjcParserConfigurationTests.allTests),
    testCase(ObjcParserTests.allTests),
    testCase(ParserTestCase.allTests),
    testCase(PartialRuleConfigurationTests.allTests),
    testCase(StringsParserTests.allTests),
    testCase(StringsdictParserTests.allTests),
    testCase(SwiftParserConfigurationTests.allTests),
    testCase(SwiftParserTests.allTests),
    testCase(UnusedRuleConfigurationTests.allTests),
    testCase(UnusedRuleTests.allTests),
    testCase(XibParserTests.allTests)
])