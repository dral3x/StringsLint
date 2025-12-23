//
//  UnusedRule.swift
//  StringsLintFrameworkTests
//
//  Created by Alessandro "Sandro" Calzavara on 12/09/2018.
//

@testable import StringsLintFramework
import XCTest

class UnusedRuleTests: XCTestCase {
    func testUnusedExample() {
        let file1 = File(name: "Localizable.strings", content: "\"abc\" = \"A B C\";")
        let file2 = File(name: "main.swift", content: "NSLocalizedString(\"def\", comment:\"\")")

        let rule = UnusedRule()
        rule.processFile(file1)
        rule.processFile(file2)

        XCTAssertEqual(rule.violations.count, 1)
        XCTAssertEqual(rule.violations[0].severity, .warning)
    }

    func testBalancedUse() {
        let file1 = File(name: "Localizable.strings", content: "\"loading\" = \"Loading...\";")
        let file2 = File(name: "main.swift", content: "NSLocalizedString(\"loading\", comment: \"\")")

        let rule = UnusedRule()
        rule.processFile(file1)
        rule.processFile(file2)

        XCTAssertEqual(rule.violations.count, 0)
    }

    func testSeverityError() {
        let file1 = File(name: "Localizable.strings", content: "\"abc\" = \"A B C\";")

        let rule = UnusedRule()
        rule.severity = .error
        rule.processFile(file1)

        XCTAssertEqual(rule.violations.count, 1)
        XCTAssertEqual(rule.violations[0].severity, .error)
    }

    func testButtonWithRole() {
        let file1 = File(name: "Localizable.strings", content: "\"create_override_episode_dialog_action_create\" = \"Create a new episode\";")
        let file2 = File(
            name: "main.swift",
            content:
            """
                        Button("create_override_episode_dialog_action_create", role: .destructive) {
                            showTemplatePicker = true
                        }
            """
        )

        let rule = UnusedRule()
        rule.severity = .error
        rule.processFile(file1)
        rule.processFile(file2)

        XCTAssertEqual(rule.violations.count, 0)
    }

    func testAccessibilityLabel() {
        let file1 = File(name: "Localizable.strings", content: "\"common_done\" = \"Done\";")
        let file2 = File(
            name: "main.swift",
            content:
            """
                                            Button {
                                                viewModel.handle(event: .close)
                                            } label: {
                                                Image.dsCrossOutline24
                                            }
                                            .accessibilityLabel("common_done")
                                            .padding(.trailing)
            """
        )

        let rule = UnusedRule()
        rule.severity = .error
        rule.processFile(file1)
        rule.processFile(file2)

        XCTAssertEqual(rule.violations.count, 0)
    }

    func testNavigationTitle() {
        let file1 = File(name: "Localizable.strings", content: "\"editing_user_view_title\" = \"Editing user\";")
        let file2 = File(
            name: "main.swift",
            content:
            """
                    .navigationTitle("editing_user_view_title")
            """
        )

        let rule = UnusedRule()
        rule.severity = .error
        rule.processFile(file1)
        rule.processFile(file2)

        XCTAssertEqual(rule.violations.count, 0)
    }

    func testTextFieldTitle() {
        let file1 = File(name: "Localizable.strings", content: "\"create_rename_section_dialog_hint\" = \"Rename\";")
        let file2 = File(
            name: "main.swift",
            content:
            """
            TextField("create_rename_section_dialog_hint", text: $sectionNewName)
            """
        )

        let rule = UnusedRule()
        rule.severity = .error
        rule.processFile(file1)
        rule.processFile(file2)

        XCTAssertEqual(rule.violations.count, 0)
    }

    func testToggle() {
        let file1 = File(name: "Localizable.strings", content: "\"publishing_create_episode_explicit_title\" = \"Create\";")
        let file2 = File(
            name: "main.swift",
            content:
            """
            Toggle("publishing_create_episode_explicit_title", isOn: $state.episodeExplicitContent)
            """
        )

        let rule = UnusedRule()
        rule.severity = .error
        rule.processFile(file1)
        rule.processFile(file2)

        XCTAssertEqual(rule.violations.count, 0)
    }

    func testKeysWithInterpolation() {
        let file1 = File(name: "Localizable.strings", content: "\"publishing_progress_title.%@\" = \"Publishing %@\";")
        let file2 = File(
            name: "main.swift",
            content:
            """
                Text("publishing_progress_title.\\(state.episodeTitle)") 
            """
        )

        let rule = UnusedRule()
        rule.severity = .error
        rule.processFile(file1)
        rule.processFile(file2)

        XCTAssertEqual(rule.violations.count, 0)
    }

    func testKeysWithComplexInterpolation() {
        let file1 = File(name: "Localizable.strings", content: "\"storage_space_used.%@\" = \"Used %@\";")
        let file2 = File(
            name: "main.swift",
            content:
            """
                Text("storage_space_used.\\(ByteCountFormatter.string(fromByteCount: used, countStyle: .file))")
            """
        )

        let rule = UnusedRule()
        rule.severity = .error
        rule.processFile(file1)
        rule.processFile(file2)

        XCTAssertEqual(rule.violations.count, 0)
    }
}
