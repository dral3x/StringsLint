# Rules

* [Unused Localization](#unused-localization)
* [Missing Localization](#missing-localization)
* [Partially Localized](#partial-localization)

## Unused Localization

Identify localized strings that are not used in the code of the app.

Resolution: remove those strings.

## Missing Localization

Identify localized strings that are used in code but does not appear in the `.strings` files.

Resolution: add that strings and localize them.

## Partially Localized

Identify strings that are localized only on a subset of languages your application declare to support.

Resolution: localize those strings on the missing languages.
