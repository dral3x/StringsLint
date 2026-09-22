//
//  XCStringsParserTests.swift
//  StringsLintFrameworkTests
//

import XCTest
@testable import StringsLintFramework

class XCStringsParserTests: ParserTestCase {

    func testParseKeyTranslatedInEveryLocale() throws {
        let content = """
{
  "sourceLanguage" : "en",
  "strings" : {
    "some_key" : {
      "extractionState" : "manual",
      "localizations" : {
        "de" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Ein Ding"
          }
        },
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "A thing"
          }
        }
      }
    }
  },
  "version" : "1.0"
}
"""
        let file = try self.createTempFile("Localizable.xcstrings", with: content)

        let parser = XCStringsParser()
        let results = try parser.parse(file: file)

        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results.map { $0.key }, [ "some_key", "some_key" ])
        XCTAssertEqual(results.map { $0.table }, [ "Localizable", "Localizable" ])
        XCTAssertEqual(results.map { $0.locale }, [ .language("de"), .language("en") ])
    }

    func testParseKeyMissingInOneLocale() throws {
        let content = """
{
  "sourceLanguage" : "en",
  "strings" : {
    "some_key" : {
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "A thing"
          }
        }
      }
    }
  },
  "version" : "1.0"
}
"""
        let file = try self.createTempFile("Localizable.xcstrings", with: content)

        let parser = XCStringsParser()
        let results = try parser.parse(file: file)

        XCTAssertEqual(results.map { $0.locale }, [ .language("en") ])
    }

    func testParseUntranslatedStatesStillCountAsDeclared() throws {
        let content = """
{
  "sourceLanguage" : "en",
  "strings" : {
    "some_key" : {
      "localizations" : {
        "de" : {
          "stringUnit" : {
            "state" : "new",
            "value" : ""
          }
        },
        "fr" : {
          "stringUnit" : {
            "state" : "needs_review",
            "value" : "Une chose"
          }
        }
      }
    }
  },
  "version" : "1.0"
}
"""
        let file = try self.createTempFile("Localizable.xcstrings", with: content)

        let parser = XCStringsParser()
        let results = try parser.parse(file: file)

        XCTAssertEqual(results.map { $0.locale }, [ .language("de"), .language("en"), .language("fr") ])
    }

    func testParseSourceLanguageIsImplicitWhenOmitted() throws {
        // Xcode drops the source language localization when the value equals the key.
        let content = """
{
  "sourceLanguage" : "en",
  "strings" : {
    "some_key" : {
      "extractionState" : "manual"
    }
  },
  "version" : "1.0"
}
"""
        let file = try self.createTempFile("Localizable.xcstrings", with: content)

        let parser = XCStringsParser()
        let results = try parser.parse(file: file)

        XCTAssertEqual(results.map { $0.locale }, [ .language("en") ])
    }

    func testParseEmptyLocalizationIsNotDeclared() throws {
        let content = """
{
  "sourceLanguage" : "en",
  "strings" : {
    "some_key" : {
      "localizations" : {
        "de" : {
        },
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "A thing"
          }
        }
      }
    }
  },
  "version" : "1.0"
}
"""
        let file = try self.createTempFile("Localizable.xcstrings", with: content)

        let parser = XCStringsParser()
        let results = try parser.parse(file: file)

        XCTAssertEqual(results.map { $0.locale }, [ .language("en") ])
    }

    func testParsePluralVariations() throws {
        let content = """
{
  "sourceLanguage" : "en",
  "strings" : {
    "things_count" : {
      "localizations" : {
        "en" : {
          "variations" : {
            "plural" : {
              "one" : {
                "stringUnit" : {
                  "state" : "translated",
                  "value" : "%lld thing"
                }
              },
              "other" : {
                "stringUnit" : {
                  "state" : "translated",
                  "value" : "%lld things"
                }
              }
            }
          }
        }
      }
    }
  },
  "version" : "1.0"
}
"""
        let file = try self.createTempFile("Localizable.xcstrings", with: content)

        let parser = XCStringsParser()
        let results = try parser.parse(file: file)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.key, "things_count")
        XCTAssertEqual(results.first?.locale, .language("en"))
    }

    func testParseComment() throws {
        let content = """
{
  "sourceLanguage" : "en",
  "strings" : {
    "some_key" : {
      "comment" : "Shown on the home screen",
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "A thing"
          }
        }
      }
    }
  },
  "version" : "1.0"
}
"""
        let file = try self.createTempFile("Localizable.xcstrings", with: content)

        let parser = XCStringsParser()
        let results = try parser.parse(file: file)

        XCTAssertEqual(results.first?.comment, "Shown on the home screen")
    }

    func testParseLineNumbersPointAtTheKey() throws {
        let content = """
{
  "sourceLanguage" : "en",
  "strings" : {
    "first_key" : {
      "localizations" : {
        "de" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Eins"
          }
        },
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "One"
          }
        }
      }
    },
    "second_key" : {
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Two"
          }
        }
      }
    }
  },
  "version" : "1.0"
}
"""
        let file = try self.createTempFile("Localizable.xcstrings", with: content)

        let parser = XCStringsParser()
        let results = try parser.parse(file: file)

        XCTAssertEqual(results.map { $0.location.line }, [ 4, 4, 20 ])
    }

    func testParseKeyContainingQuotes() throws {
        let content = """
{
  "sourceLanguage" : "en",
  "strings" : {
    "a \\"quoted\\" key" : {
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "A thing"
          }
        }
      }
    }
  },
  "version" : "1.0"
}
"""
        let file = try self.createTempFile("Localizable.xcstrings", with: content)

        let parser = XCStringsParser()
        let results = try parser.parse(file: file)

        XCTAssertEqual(results.map { $0.key }, [ "a \"quoted\" key" ])
        XCTAssertEqual(results.map { $0.location.line }, [ 4 ])
    }

    func testParseSkipsStringsMarkedDoNotTranslate() throws {
        // "Don't translate" strings only ever hold the source language, so treating them as
        // declared would report them missing in every other locale.
        let content = """
{
  "sourceLanguage" : "en",
  "strings" : {
    "brand_name" : {
      "shouldTranslate" : false,
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Freeletics"
          }
        }
      }
    },
    "some_key" : {
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "A thing"
          }
        }
      }
    }
  },
  "version" : "1.0"
}
"""
        let file = try self.createTempFile("Localizable.xcstrings", with: content)

        let parser = XCStringsParser()
        let results = try parser.parse(file: file)

        XCTAssertEqual(results.map { $0.key }, [ "some_key" ])
    }

    func testParseLineNumbersWithoutSpacesAroundTheColon() throws {
        let content = """
{
  "sourceLanguage": "en",
  "strings": {
    "some_key": {
      "localizations": {
        "en": {
          "stringUnit": {
            "state": "translated",
            "value": "A thing"
          }
        }
      }
    }
  },
  "version": "1.0"
}
"""
        let file = try self.createTempFile("Localizable.xcstrings", with: content)

        let parser = XCStringsParser()
        let results = try parser.parse(file: file)

        XCTAssertEqual(results.map { $0.location.line }, [ 4 ])
    }

    func testParseMalformedCatalogThrows() throws {
        let file = try self.createTempFile("Localizable.xcstrings", with: "{ not json")

        let parser = XCStringsParser()

        XCTAssertThrowsError(try parser.parse(file: file))
    }

    func testParseEmptyCatalog() throws {
        let content = """
{
  "sourceLanguage" : "en",
  "strings" : {

  },
  "version" : "1.0"
}
"""
        let file = try self.createTempFile("Localizable.xcstrings", with: content)

        let parser = XCStringsParser()
        let results = try parser.parse(file: file)

        XCTAssertEqual(results.count, 0)
    }

    func testSupportedFiles() {
        let parser = XCStringsParser()

        XCTAssertTrue(parser.support(file: File(name: "Localizable.xcstrings", content: "")))
        XCTAssertFalse(parser.support(file: File(name: "Localizable.strings", content: "")))
    }
}
