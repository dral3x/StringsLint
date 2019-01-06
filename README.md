# StringsLint

A tool to ensure localized strings are complete and never unused.

StringsLint hooks into your source files, specifically it scans:

- .`strings`
- .`swift` and .`m`
- .`xib` and `.storyboard`

![Test Status](https://travis-ci.org/dral3x/StringsLint.svg?branch=master)

![](assets/results.png)

If you **found a bug** or **have a feature request**, please open an issue.
If you **want to contribute**, submit a pull request.


## Installation

### Using [Homebrew](http://brew.sh/) ⚠️ Not available yet!

In order to distribute this tool via Homebrew, we need to address these problems:

```bash
brew audit --new-formula --strict stringslint
stringslint:
  * GitHub repository not notable enough (<30 forks, <30 watchers and <75 stars)
  * GitHub repository too new (<30 days old)
```

Once these are knocked down, you will install it like so

```bash
brew install stringslint
```

### Compiling from source:

You can build from source by cloning this project and running `make install` (Xcode 10.0 or later).

## Usage

### Xcode

Integrate StringsLint into an Xcode scheme to get warnings and errors displayed
in the IDE. Just add a new "Run Script Phase" with:

```bash
if which stringslint >/dev/null; then
  stringslint
else
  echo "warning: StringsLint not installed, download from https://github.com/dral3x/StringsLint"
fi
```

![](assets/runscript.png)


### Command Line

```
$ stringslint help
Available commands:

help            Display general or command-specific help
lint            Print lint warnings and errors (default command)
version         Display the current version of StringsLint
```

Run `stringslint` in the directory containing the files to lint.
Directories will be searched recursively.

## Rules

There are few basic but important rules included.
See [Rules.md](Rules.md) for more information.

You can also check [Sources/StringsLintFramework/Rules/Lint](Sources/StringsLintFramework/Rules/Lint) directory to see their implementation.

### Configuration

Configure StringsLint by adding a `.stringslint.yml` file from the directory you'll run StringsLint from.
You can configure included and excluded file paths, extends some parsers capabilities and even turn off rules or specific files for each rule:

```yaml

included: # paths to include during linting. `--path` is ignored if present.
- Source
excluded: # paths to ignore during linting. Takes precedence over `included`.
- Carthage
- Pods
- Source/ExcludedFolder
- Source/ExcludedFile.swift
- Source/*/ExcludedFile.swift # Exclude files with a wildcard

# Customize parsers
objc_parser:
  implicit_macros:
    - SPKLocalizedString # detect this custom macro

xib_parser:
  key_paths:
    - textLocalized # keyPath used to localized UI elements

# Customize specific rules
unused:
  excluded:
    - InfoPlist.strings # strings in here are used by iOS directly

```

## License

[MIT licensed.](LICENSE)
