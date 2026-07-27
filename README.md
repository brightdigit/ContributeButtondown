# ContributeButtondown


[![Swift Versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FContributeButtondown%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/brightdigit/ContributeButtondown)
[![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FContributeButtondown%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/brightdigit/ContributeButtondown)
[![Documentation](https://img.shields.io/badge/docc-read_documentation-blue)](https://swiftpackageindex.com/brightdigit/ContributeButtondown/documentation)
[![License](https://img.shields.io/github/license/brightdigit/ContributeButtondown)](LICENSE)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/brightdigit/ContributeButtondown/ContributeButtondown.yml?label=actions&logo=github&branch=main)](https://github.com/brightdigit/ContributeButtondown/actions)
[![Maintainability](https://qlty.sh/gh/brightdigit/projects/ContributeButtondown/maintainability.svg)](https://qlty.sh/gh/brightdigit/projects/ContributeButtondown)
[![Codecov](https://img.shields.io/codecov/c/github/brightdigit/ContributeButtondown)](https://codecov.io/gh/brightdigit/ContributeButtondown)
[![CodeFactor Grade](https://img.shields.io/codefactor/grade/github/brightdigit/ContributeButtondown)](https://www.codefactor.io/repository/github/brightdigit/ContributeButtondown)

Create content for your site from Buttondown newsletters.

---

## What is ContributeButtondown?

Your newsletter archive is already a body of writing — it just lives in Buttondown instead of your
site's content folder. **ContributeButtondown turns Buttondown emails into Markdown files with YAML
front matter**, one file per issue, ready for a static site generator to pick up.

It is the Buttondown binding for [Contribute](https://github.com/brightdigit/Contribute), the
generic *source model → markdown file* pipeline, and it consumes
[ButtondownKit](https://github.com/brightdigit/ButtondownKit)'s `Email` model. Contribute supplies
the write loop, ButtondownKit supplies the API types, and this package is the thin, opinionated
layer in between.

Two things make it more than a field mapping:

- **No HTML round-trip.** Buttondown's plaintext editor stores issue bodies as Markdown already, so
  the body is copied through verbatim rather than converted out of HTML. The only cleanup is
  stripping the leading `<!-- buttondown-editor-mode: plaintext -->` marker Buttondown prepends.
- **Issue numbering that survives repeated imports.** Newsletter archives are numbered; Buttondown
  subjects are not reliably. This package parses an issue number out of subjects where present,
  assigns sequential numbers oldest-first where absent, and *filters already-imported issues before
  numbering* — so running the import again is idempotent instead of re-importing the same email
  under a fresh number. The subject marker is configurable: `IssueNumbering.default` recognizes the
  common `Issue N` / `Issue #N` form, and `IssueNumbering(subjectPattern:)` takes your own.

`brightdigit.com` uses it to import the BrightDigit newsletter archive, continuing the numbering
from the Mailchimp-era issues it replaced.

> **Scope:** ContributeButtondown does **not** call the Buttondown API. You bring the already-decoded
> `Email` values — fetch them with [ButtondownKit](https://github.com/brightdigit/ButtondownKit).
> This package's job starts there: **email → markdown file.**

## Installation

Add ContributeButtondown to your `Package.swift`:

```swift
dependencies: [
  .package(url: "https://github.com/brightdigit/ContributeButtondown.git", from: "1.0.0-alpha.1")
]
```

Then add it to a target:

```swift
.target(
  name: "MySite",
  dependencies: [.product(name: "ContributeButtondown", package: "ContributeButtondown")]
)
```

## Usage

`Newsletter` is the entry point — a `Contribute.ContentType` binding a source model, a front-matter
translator, and a markdown extractor.

### 1. Pick the issues to import

Hand your sent emails, plus what you already have on disk, to
`newIssues(from:continuingFrom:existingIssueNumbers:existingSlugs:slug:numbering:)`:

```swift
import ButtondownKit
import ContributeButtondown

let slug: (Email) -> String = { makeSlug(from: $0.subject) }

let numbered = Newsletter.newIssues(
  from: sentEmails,                        // [ButtondownKit.Email]
  continuingFrom: 117,                     // highest issue number already on disk
  existingIssueNumbers: existingNumbers,   // Set<Int>
  existingSlugs: existingSlugs,            // Set<String>, from your NNN-slug.md file names
  slug: slug
)
```

Each result is a `Newsletter.NumberedEmail` — the email plus the issue number assigned to it, in
oldest-first order.

The `numbering:` parameter describes how an explicit issue number is recognized in a subject. It
defaults to `IssueNumbering.default`, which matches the common `Issue N` / `Issue #N` form. If your
subjects number issues differently, pass your own pattern — its first capture group is read as the
number:

```swift
// Subjects like "Weekly #42 — what shipped"
let numbering = try IssueNumbering(subjectPattern: #"(?i)weekly\s*#?\s*(\d+)"#)

let numbered = Newsletter.newIssues(
  from: sentEmails,
  continuingFrom: localMax,
  existingIssueNumbers: existingNumbers,
  existingSlugs: existingSlugs,
  slug: slug,
  numbering: numbering
)
```

A subject with no match carries no explicit number and falls back to sequential numbering.

### 2. Resolve each one into a source

```swift
let sources = try numbered.map {
  try Newsletter.Source(
    email: $0.email,
    issueNo: $0.issueNo,
    slug: slug($0.email),
    featuredImageFallback: fallbackImageURL
  )
}
```

`Newsletter.Source` throws `ButtondownImportError.malformedArchiveURL` when an email's archive URL
will not parse, and substitutes `featuredImageFallback` when the email carries no image — so the
front matter's required `featuredImage` is always present.

### 3. Write the files

```swift
import Contribute
import Foundation

try Newsletter.write(
  from: sources,
  atContentPathURL: URL(fileURLWithPath: "Content/newsletters"),
  fileNameWithoutExtension: { "\($0.issueNo)-\($0.slug)" },
  using: PassthroughMarkdownGenerator.shared.markdown(fromHTML:),
  options: .init(shouldOverwriteExisting: false, includeMissingPrevious: true)
)
```

`PassthroughMarkdownGenerator` is the right converter here precisely because the body is already
Markdown. Each file comes out as YAML front matter followed by the issue body:

```markdown
---
issueNo: 118
buttondownID: 5a1b2c3d-4e5f-6789-abcd-ef0123456789
featuredImage: https://example.com/newsletter-118.png
longArchiveURL: https://buttondown.com/brightdigit/archive/issue-118/
title: 'Swift on the Server - Issue #118'
date: '2026-06-29 12:00'
description: What shipped this week.
---

The issue body, exactly as written in Buttondown.
```

`buttondownID` is retained for provenance and reversibility; site generators that tolerate unknown
metadata keys simply ignore it.

### Using your own front matter

That field set is what brightdigit.com's newsletter section reads — a sensible default, not a
requirement. The front matter is any `Encodable`, so a site with a different schema supplies its own
translator rather than reimplementing the importer:

```swift
struct MyFrontMatter: Encodable {
  let headline: String
  let publishedAt: String
  let tags: [String]
}

struct MyTranslator: Contribute.FrontMatterTranslator {
  let tags: [String]                       // per-site config lives here
  init() { tags = [] }
  init(tags: [String]) { self.tags = tags }

  func frontMatter(from source: Newsletter.Source) -> MyFrontMatter {
    MyFrontMatter(
      headline: source.title,
      publishedAt: YAML.dateFormatter.string(from: source.date),
      tags: tags
    )
  }
}

try Newsletter.write(
  from: sources,
  atContentPathURL: URL(fileURLWithPath: "Content/newsletters"),
  fileNameWithoutExtension: { "\($0.issueNo)-\($0.slug)" },
  using: PassthroughMarkdownGenerator.shared.markdown(fromHTML:),
  translatedBy: MyTranslator(tags: ["newsletter"])
)
```

This overload takes a translator **instance**, so a translator can carry configuration — the
`ContentType` path can't, since it default-constructs its translator. `Newsletter.FrontMatter` also
has a public memberwise initializer, if you'd rather wrap or extend the default shape than replace
it.

## Requirements

- Swift 6.4 (`.swift-version` → `6.4.x-snapshot`)
- macOS 15+, iOS 16+, tvOS 16+, watchOS 9+
- Ubuntu 24.04 (Noble); Windows and Android are covered by CI

## License

[MIT](LICENSE) © BrightDigit
