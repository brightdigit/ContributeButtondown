//
//  NewsletterTranslationTests.swift
//  BrightDigit
//
//  Created by Leo Dion.
//  Copyright © 2026 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import ButtondownKit
import Contribute
import Foundation
import Testing

@testable import ContributeButtondown

/// Exercises `Email → Source → FrontMatter` mapping and the full content build.
@Suite internal struct NewsletterTranslationTests {
  private static let fallbackImage: URL = {
    guard
      let url = URL(string: "https://brightdigit.com/android-chrome-512x512.png")
    else {
      preconditionFailure("Invalid fallback image URL")
    }
    return url
  }()

  /// A `Source` built from an email carries the email fields, and the translator
  /// maps them onto the front matter (with the date formatted via `YAML`).
  @Test internal func translatesSourceToFrontMatter() throws {
    let email = Fixtures.email(
      subject: "Issue #118",
      daysAfterEpoch: 100,
      id: "abc-123",
      body: "# Hello",
      absoluteURL: "https://buttondown.com/brightdigit/archive/issue-118/",
      description: "The 118th issue.",
      image: "https://example.com/cover.png"
    )
    let source = try Newsletter.Source(
      email: email,
      issueNo: 118,
      slug: "issue-118",
      featuredImageFallback: Self.fallbackImage
    )
    let frontMatter = Newsletter.FrontMatterTranslator().frontMatter(from: source)

    #expect(frontMatter.issueNo == 118)
    #expect(frontMatter.buttondownID == "abc-123")
    #expect(frontMatter.title == "Issue #118")
    #expect(frontMatter.description == "The 118th issue.")
    #expect(
      frontMatter.longArchiveURL
        == URL(string: "https://buttondown.com/brightdigit/archive/issue-118/")
    )
    #expect(frontMatter.featuredImage == URL(string: "https://example.com/cover.png"))
    #expect(frontMatter.date == YAML.dateFormatter.string(from: email.creationDate))
    #expect(source.markdown == "# Hello")
  }

  /// An email with no image falls back to the supplied featured image, so the
  /// site's required `featuredImage` metadata is always emitted.
  @Test internal func emptyImageFallsBack() throws {
    let email = Fixtures.email(subject: "Issue #119", daysAfterEpoch: 101, image: "")
    let source = try Newsletter.Source(
      email: email,
      issueNo: 119,
      slug: "issue-119",
      featuredImageFallback: Self.fallbackImage
    )
    #expect(source.featuredImageURL == Self.fallbackImage)
  }

  /// A malformed `absolute_url` surfaces as a typed import error rather than a
  /// silent bad URL.
  @Test internal func malformedArchiveURLThrows() {
    let email = Fixtures.email(
      subject: "Issue #120",
      daysAfterEpoch: 102,
      id: "bad-url",
      absoluteURL: ""
    )
    #expect(
      throws: ButtondownImportError.malformedArchiveURL(emailID: "bad-url", value: "")
    ) {
      _ = try Newsletter.Source(
        email: email,
        issueNo: 120,
        slug: "issue-120",
        featuredImageFallback: Self.fallbackImage
      )
    }
  }

  /// The full content build emits YAML front matter (delimited by `---`) with
  /// the mapped fields, followed by the Markdown body copied from Buttondown.
  @Test internal func buildsMarkdownWithFrontMatter() throws {
    let email = Fixtures.email(
      subject: "Issue #118",
      daysAfterEpoch: 100,
      body: "<!-- buttondown-editor-mode: plaintext -->\n\n# Hello world"
    )
    let source = try Newsletter.Source(
      email: email,
      issueNo: 118,
      slug: "issue-118",
      featuredImageFallback: Self.fallbackImage
    )
    let content = try Newsletter.contentBuilder().content(from: source) { _ in
      Issue.record("Buttondown Markdown must not be passed through the HTML converter")
      return "converted"
    }

    #expect(content.hasPrefix("---\n"))
    #expect(content.contains("issueNo: 118"))
    #expect(content.contains("buttondownID:"))
    // `#` starts a YAML comment, so the subject is emitted as a quoted scalar.
    #expect(content.contains("Issue #118"))
    #expect(content.contains("longArchiveURL:"))
    #expect(content.contains("featuredImage:"))
    // Body follows the closing front-matter delimiter.
    #expect(content.contains("---\n# Hello world"))
    #expect(!content.contains("buttondown-editor-mode"))
  }
}
