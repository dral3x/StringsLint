TEMPORARY_FOLDER?=/tmp/StringsLint.dst
PREFIX?=/usr/local
BUILD_TOOL?=xcodebuild

XCODEFLAGS=-workspace 'StringsLint.xcworkspace' \
	-scheme 'stringslint' \
	DSTROOT=$(TEMPORARY_FOLDER) \
	OTHER_LDFLAGS=-Wl,-headerpad_max_install_names

SWIFT_BUILD_FLAGS=--configuration release
UNAME=$(shell uname)
ifeq ($(UNAME), Darwin)
USE_SWIFT_STATIC_STDLIB:=$(shell test -d $$(dirname $$(xcrun --find swift))/../lib/swift_static/macosx && echo yes)
ifeq ($(USE_SWIFT_STATIC_STDLIB), yes)
SWIFT_BUILD_FLAGS+= -Xswiftc -static-stdlib
endif
endif

STRINGSLINT_EXECUTABLE=$(shell swift build $(SWIFT_BUILD_FLAGS) --show-bin-path)/stringslint

TSAN_LIB=$(subst bin/swift,lib/swift/clang/lib/darwin/libclang_rt.tsan_osx_dynamic.dylib,$(shell xcrun --find swift))
TSAN_SWIFT_BUILD_FLAGS=-Xswiftc -sanitize=thread
TSAN_TEST_BUNDLE=$(shell swift build $(TSAN_SWIFT_BUILD_FLAGS) --show-bin-path)/StringsLintPackageTests.xctest
TSAN_XCTEST=$(shell xcrun --find xctest)

FRAMEWORKS_FOLDER=/Library/Frameworks
BINARIES_FOLDER=/usr/local/bin
LICENSE_PATH="$(shell pwd)/LICENSE"

OUTPUT_PACKAGE=StringsLint.pkg

STRINGSLINT_PLIST=Sources/StringsLint/Supporting Files/Info.plist
STRINGSLINTFRAMEWORK_PLIST=Sources/StringsLintFramework/Supporting Files/Info.plist

VERSION_STRING=$(shell /usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$(STRINGSLINT_PLIST)")

.PHONY: all clean build install package test uninstall

all: build

sourcery: Tests/LinuxMain.swift

Tests/LinuxMain.swift: Tests/*/*.swift .sourcery/LinuxMain.stencil
	sourcery --sources Tests --exclude-sources Tests/StringsLintFrameworkTests/Resources --templates .sourcery/LinuxMain.stencil --output .sourcery --force-parse generated
	mv .sourcery/LinuxMain.generated.swift Tests/LinuxMain.swift

clean:
	rm -f "$(OUTPUT_PACKAGE)"
	rm -rf "$(TEMPORARY_FOLDER)"
	rm -f "./portable_swiftlint.zip"
	swift package clean

clean_xcode: clean
	$(BUILD_TOOL) $(XCODEFLAGS) -configuration Test clean

test: clean_xcode
	$(BUILD_TOOL) $(XCODEFLAGS) test

test_tsan:
	swift build --build-tests $(TSAN_SWIFT_BUILD_FLAGS)
	DYLD_INSERT_LIBRARIES=$(TSAN_LIB) $(TSAN_XCTEST) $(TSAN_TEST_BUNDLE)

build:
	swift build $(SWIFT_BUILD_FLAGS)

build_with_disable_sandbox:
	swift build --disable-sandbox $(SWIFT_BUILD_FLAGS)

install: clean build
	install -d "$(BINARIES_FOLDER)"
	install "$(STRINGSLINT_EXECUTABLE)" "$(BINARIES_FOLDER)"

uninstall:
	rm -rf "$(FRAMEWORKS_FOLDER)/StringsLintFramework.framework"
	rm -f "$(BINARIES_FOLDER)/stringslint"

installables: build
	install -d "$(TEMPORARY_FOLDER)$(BINARIES_FOLDER)"
	install "$(STRINGSLINT_EXECUTABLE)" "$(TEMPORARY_FOLDER)$(BINARIES_FOLDER)"

prefix_install: clean build_with_disable_sandbox
	install -d "$(PREFIX)/bin/"
	install "$(STRINGSLINT_EXECUTABLE)" "$(PREFIX)/bin/"

portable_zip: installables
	cp -f "$(TEMPORARY_FOLDER)$(BINARIES_FOLDER)/stringslint" "$(TEMPORARY_FOLDER)"
	cp -f "$(LICENSE_PATH)" "$(TEMPORARY_FOLDER)"
	(cd "$(TEMPORARY_FOLDER)"; zip -yr - "stringslint" "LICENSE") > "./portable_stringslint.zip"

package: installables
	pkgbuild \
		--identifier "com.alessandrocalzavara.stringslint" \
		--install-location "/" \
		--root "$(TEMPORARY_FOLDER)" \
		--version "$(VERSION_STRING)" \
		"$(OUTPUT_PACKAGE)"

release: package portable_zip

publish:
	#brew update && brew bump-formula-pr --tag=$(shell git describe --tags) --revision=$(shell git rev-parse HEAD) stringslint
	pod trunk push StringsLint.podspec

get_version:
	@echo $(VERSION_STRING)

# make push_version <VERSION>: <NAME>
push_version:
ifneq ($(strip $(shell git status --untracked-files=no --porcelain 2>/dev/null)),)
	$(error git state is not clean)
endif
	$(eval NEW_VERSION_AND_NAME := $(filter-out $@,$(MAKECMDGOALS)))
	$(eval NEW_VERSION := $(shell echo $(NEW_VERSION_AND_NAME) | sed 's/:.*//' ))
	@sed -i '' 's/## Master/## $(NEW_VERSION_AND_NAME)/g' CHANGELOG.md
	@sed 's/__VERSION__/$(NEW_VERSION)/g' script/Version.swift.template > Sources/StringsLintFramework/Models/Version.swift
	@/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $(NEW_VERSION)" "$(STRINGSLINTFRAMEWORK_PLIST)"
	@/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $(NEW_VERSION)" "$(STRINGSLINT_PLIST)"
	git commit -a -m "release $(NEW_VERSION)"
	git tag -a $(NEW_VERSION) -m "$(NEW_VERSION_AND_NAME)"
	git push origin master
	git push origin $(NEW_VERSION)

%:
	@: