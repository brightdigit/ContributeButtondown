# Release Notes

## 1.0.0-alpha.1

### Library
* Establish ContributeButtondown as a standalone package: the Buttondown binding for Contribute that turns Buttondown emails into Markdown files with YAML front matter by @leogdion in https://github.com/brightdigit/ContributeButtondown/pull/1
* Add a public `IssueNumbering` type holding the subject regex, with `.default` preserving the prior `Issue N` / `Issue #N` behavior and a throwing `init(subjectPattern:)` since the pattern is consumer input by @leogdion in https://github.com/brightdigit/ContributeButtondown/pull/1
* Thread issue numbering through the import as a defaulted `numbering:` parameter, backed by `Newsletter+IssueNumbering` and a dedicated `IssueNumberingError` by @leogdion in https://github.com/brightdigit/ContributeButtondown/pull/1
* Give `Newsletter.FrontMatter` a public memberwise `init` so consumers can construct front matter directly by @leogdion in https://github.com/brightdigit/ContributeButtondown/pull/1
* Make `write(…translatedBy:)` take a `FrontMatterTranslator` instance so a site can emit any `Encodable` front-matter schema by @leogdion in https://github.com/brightdigit/ContributeButtondown/pull/1
* Provide the Contribute trio — `Newsletter.Source`, `Newsletter.FrontMatterTranslator`, and `Newsletter.MarkdownExtractor` — plus a typed `ButtondownImportError` by @leogdion in https://github.com/brightdigit/ContributeButtondown/pull/1
* Build against the Swift 6.4 toolchain with complete strict concurrency, targeting macOS 15 / iOS 16 / tvOS 16 / watchOS 9 by @leogdion in https://github.com/brightdigit/ContributeButtondown/pull/1

### Tests
* Add test coverage for issue numbering, newsletter translation, and custom front matter (`IssueNumberingTests`, `NewsletterTranslationTests`, `CustomFrontMatterTests`) by @leogdion in https://github.com/brightdigit/ContributeButtondown/pull/1

### Documentation
* Add a README covering the Markdown pass-through (no HTML round-trip), the plaintext-editor marker stripping, and idempotent issue numbering, plus a `ContributeButtondown.docc` catalog by @leogdion in https://github.com/brightdigit/ContributeButtondown/pull/1
* Remove the placeholder logo PNG by @leogdion in https://github.com/brightdigit/ContributeButtondown/pull/1

### Dependencies
* Depend on Contribute for the write loop and ButtondownKit for the `Email` model by @leogdion in https://github.com/brightdigit/ContributeButtondown/pull/1

### Tooling & CI
* Set up mise-based linting and formatting with `.mise.toml`, `.swift-format`, `.swiftlint.yml`, `.periphery.yml`, `Scripts/lint.sh`, and `Scripts/header.sh` by @leogdion in https://github.com/brightdigit/ContributeButtondown/pull/1
* Add the shared multi-platform CI template (macOS/Linux/Windows/Android) along with `check-unsafe-flags`, `swift-source-compat`, `cleanup-caches`, and Claude review workflows by @leogdion in https://github.com/brightdigit/ContributeButtondown/pull/1
* Add a devcontainer, Dependabot config, `.swift-version` pin, `codecov.yml`, `.spi.yml`, `LICENSE`, and `AGENTS.md` agent instructions by @leogdion in https://github.com/brightdigit/ContributeButtondown/pull/1
