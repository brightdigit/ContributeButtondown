# ``ContributeButtondown``

Import Buttondown newsletter issues into Markdown files with YAML front matter.

## Overview

ContributeButtondown bridges [ButtondownKit](https://github.com/brightdigit/ButtondownKit)'s
API models into the [Contribute](https://github.com/brightdigit/Contribute) import pipeline.
Give it the emails you fetched from Buttondown and it produces one Markdown file per issue,
ready to drop into a static site's content folder.

``Newsletter`` is the entry point. It conforms to `Contribute`'s `ContentType`, binding three
pieces together:

- ``Newsletter/Source`` — a fully-resolved issue: slug, issue number, Buttondown email id,
  archive URL, featured image, title, description, date, and Markdown body. Build one from a
  `ButtondownKit.Email` with ``Newsletter/Source/init(email:issueNo:slug:featuredImageFallback:)``.
- ``Newsletter/FrontMatterTranslator`` — maps a source onto ``Newsletter/FrontMatter``, the YAML
  front matter written above the body.
- ``Newsletter/MarkdownExtractor`` — copies the body through. Buttondown's plaintext editor
  already stores Markdown, so no HTML conversion happens; the extractor only strips the leading
  `<!-- buttondown-editor-mode: plaintext -->` marker.

### Issue numbering

Newsletter archives are numbered, but not every Buttondown subject carries its number.
``Newsletter/parseIssueNumber(fromSubject:)`` recognizes the `Issue N` and `Issue #N` forms,
``Newsletter/assignIssueNumbers(to:continuingFrom:)`` sorts emails oldest-first and fills in
sequential numbers for the rest, and ``Newsletter/newIssues(from:continuingFrom:existingIssueNumbers:existingSlugs:slug:)``
drops the issues already on disk *before* numbering, which is what keeps repeated imports
idempotent.

### Writing files

Once you have sources, `Contribute`'s generic `write(...)` on `ContentType` does the rest:

```swift
import Contribute
import ContributeButtondown

// Your own subject → file-name-safe slug rule.
let slug: (Email) -> String = { makeSlug(from: $0.subject) }

let numbered = Newsletter.newIssues(
  from: emails,
  continuingFrom: 117,
  existingIssueNumbers: existingNumbers,
  existingSlugs: existingSlugs,
  slug: slug
)

let sources = try numbered.map {
  try Newsletter.Source(
    email: $0.email,
    issueNo: $0.issueNo,
    slug: slug($0.email),
    featuredImageFallback: fallbackImageURL
  )
}

try Newsletter.write(
  from: sources,
  atContentPathURL: URL(fileURLWithPath: "Content/newsletters"),
  fileNameWithoutExtension: { "\($0.issueNo)-\($0.slug)" },
  using: PassthroughMarkdownGenerator.shared.markdown(fromHTML:),
  options: .init(shouldOverwriteExisting: false, includeMissingPrevious: true)
)
```

## Topics

### Content type

- ``Newsletter``
- ``Newsletter/Source``
- ``Newsletter/FrontMatter``
- ``Newsletter/FrontMatterTranslator``
- ``Newsletter/MarkdownExtractor``

### Issue numbering

- ``Newsletter/NumberedEmail``
- ``Newsletter/parseIssueNumber(fromSubject:)``
- ``Newsletter/assignIssueNumbers(to:continuingFrom:)``
- ``Newsletter/newIssues(from:continuingFrom:existingIssueNumbers:existingSlugs:slug:)``

### Errors

- ``ButtondownImportError``
