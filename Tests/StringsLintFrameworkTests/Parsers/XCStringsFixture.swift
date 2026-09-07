//
//  XCStringsFixture.swift
//  StringsLintFrameworkTests
//

enum XCStringsFixture {
    static func catalog(key: String, comment: String? = nil) -> String {
        let commentLine = comment.map { "      \"comment\" : \"\($0)\",\n" } ?? ""

        return """
{
  "sourceLanguage" : "en",
  "strings" : {
    "\(key)" : {
\(commentLine)      "localizations" : {
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
    }
}
