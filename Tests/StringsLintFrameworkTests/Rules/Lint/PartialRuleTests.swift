//
//  PartialRuleTests.swift
//  StringsLintFrameworkTests
//

@testable import StringsLintFramework
import XCTest

class PartialRuleTests: ParserTestCase {

    func testStringsFileMissingATranslation() throws {
        let german = try self.createTempFile("Localizable.strings", with: "\"abc\" = \"A B C\";", path: "/partial1/de.lproj")
        let french = try self.createTempFile("Localizable.strings", with: "", path: "/partial1/fr.lproj")

        let rule = PartialRule()
        rule.processFile(german)
        rule.processFile(french)

        XCTAssertEqual(rule.violations.count, 1)
        XCTAssertEqual(rule.violations[0].reason, "Localized string \"abc\" is missing in locale \"fr\"")
    }

    func testStringsFilesFullyTranslated() throws {
        let german = try self.createTempFile("Localizable.strings", with: "\"abc\" = \"A B C\";", path: "/partial2/de.lproj")
        let french = try self.createTempFile("Localizable.strings", with: "\"abc\" = \"A B C\";", path: "/partial2/fr.lproj")

        let rule = PartialRule()
        rule.processFile(german)
        rule.processFile(french)

        XCTAssertEqual(rule.violations.count, 0)
    }

    func testStringCatalogMissingATranslation() throws {
        let content = """
{
  "sourceLanguage" : "en",
  "strings" : {
    "abc" : {
      "localizations" : {
        "de" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "A B C"
          }
        },
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "A B C"
          }
        }
      }
    },
    "def" : {
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "D E F"
          }
        }
      }
    }
  },
  "version" : "1.0"
}
"""
        let catalog = try self.createTempFile("Localizable.xcstrings", with: content, path: "/partial3")

        let rule = PartialRule()
        rule.processFile(catalog)

        XCTAssertEqual(rule.violations.count, 1)
        XCTAssertEqual(rule.violations[0].reason, "Localized string \"def\" is missing in locale \"de\"")
    }

    func testStringCatalogFullyTranslated() throws {
        let content = """
{
  "sourceLanguage" : "en",
  "strings" : {
    "abc" : {
      "localizations" : {
        "de" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "A B C"
          }
        },
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "A B C"
          }
        }
      }
    }
  },
  "version" : "1.0"
}
"""
        let catalog = try self.createTempFile("Localizable.xcstrings", with: content, path: "/partial4")

        let rule = PartialRule()
        rule.processFile(catalog)

        XCTAssertEqual(rule.violations.count, 0)
    }
}
