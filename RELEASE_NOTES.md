# Release Notes

## Unreleased

Wave 1 merge (brightdigit/ContributeButtondown #1, head `brightdigit-com-260717`) — the
initial content of this package, split out of the brightdigit.com monorepo via
`git subrepo push` and tied to `main` with an unrelated-histories merge so the diff is
reviewable.

### Library

- Initial `ContributeButtondown` library: `Newsletter`, a `Contribute.ContentType` that
  imports Buttondown newsletter emails into Markdown with YAML front matter.
- `Newsletter.Source` resolves a `ButtondownKit.Email` into an importable issue (slug,
  issue number, archive URL, featured image, title, description, date, Markdown body),
  falling back to a supplied image URL when the email has none and throwing
  `ButtondownImportError.malformedArchiveURL` when `absoluteURL` cannot be parsed.
- `Newsletter.FrontMatter` and `Newsletter.FrontMatterTranslator` emit the front-matter
  field set brightdigit.com's newsletter section reads, retaining `buttondownID` for
  provenance. That schema is a default, not a contract: `FrontMatter` exposes a public
  memberwise initializer, and `write(…translatedBy:)` accepts any
  `Contribute.FrontMatterTranslator` instance, so a site with a different schema supplies
  its own `Encodable` front matter without reimplementing the importer. Passing an instance
  (rather than the `ContentType` typealias, which is default-constructed) also lets a
  translator carry per-site configuration.
- `Newsletter.MarkdownExtractor` copies Buttondown's plaintext-editor body through
  verbatim, stripping the `<!-- buttondown-editor-mode: plaintext -->` marker.
- `Newsletter+IssueNumbering` parses explicit issue numbers out of subjects, assigns
  sequential numbers oldest-first, and filters already-imported issues before numbering
  so repeated imports are idempotent.
- `IssueNumbering` makes the subject marker configurable: `.default` recognizes the common
  `Issue N` / `Issue #N` form, and `init(subjectPattern:)` accepts any pattern whose first
  capture group holds the number, throwing on an invalid one. Every numbering entry point
  takes it as a defaulted `numbering:` parameter.

### Tests

- swift-testing suites `IssueNumberingTests` and `NewsletterTranslationTests`, plus
  offline `Fixtures` that build `ButtondownKit.Email` values with deterministic dates.

### CI

- Adopted the shared BrightDigit workflow template as
  `.github/workflows/ContributeButtondown.yml` (Ubuntu, macOS, Apple platforms, Windows,
  Android) alongside the five auxiliary workflows and the `setup-tools` composite action.
- Package dependencies (`Contribute`, `ButtondownKit`) resolve from their GitHub
  repositories rather than monorepo paths, so the package builds standalone.
- Ubuntu coverage now uses `sersoft-gmbh/swift-coverage-action@v5`; matrix legs run with
  `fail-fast: true`; the visionOS simulator leg was added and the `ENABLE_WATCHOS` gate
  removed.
- Repository hygiene: `codecov.yml`, `.github/dependabot.yml`, shared `.swift-format` /
  `.swiftlint.yml`, `AGENTS.md` (with `CLAUDE.md` as a symlink), `.claude/` agent notes
  and skills, a DocC catalog, and a rewritten README.
