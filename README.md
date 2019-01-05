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

### Using [Homebrew](http://brew.sh/):

```
brew install stringslint
```

### Using a pre-built package:

You can also install StringsLint by downloading `StringsLint.pkg` from the [latest GitHub release](https://github.com/dral3x/StringsLint/releases/latest) and running it.

### Compiling from source:

You can also build from source by cloning this project and running
`make install` (Xcode 9.4 or later).

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

There are very few rules included, but [Pull requests](CONTRIBUTING.md) are encouraged.

You can find an updated list of rules and more information about them in [Rules.md](Rules.md).

You can also check [Sources/StringsLintFramework/Rules](Sources/StringsLintFramework/Rules) directory to see their implementation.

### Configuration

Configure StringsLint by adding a `.stringslint.yml` file from the directory you'll run StringsLint from. 
The following parameters can be configured:

```yaml

included: # paths to include during linting. `--path` is ignored if present.
- Source
excluded: # paths to ignore during linting. Takes precedence over `included`.
- Carthage
- Pods
- Source/ExcludedFolder
- Source/ExcludedFile.swift
- Source/*/ExcludedFile.swift # Exclude files with a wildcard
```

You can also use environment variables in your configuration file, by using `${SOME_VARIABLE}` in a string.

## License

[MIT licensed.](LICENSE)
