//
//  CustomFrontMatterTests.swift
//  ContributeButtondown
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

import Contribute
import Foundation
import Testing

@testable import ContributeButtondown

/// Proves a consumer can emit a front-matter schema of its own, without
/// reimplementing the importer.
///
/// `Newsletter.FrontMatter` is brightdigit.com's field set; this suite stands in
/// for a site that needs a different one.
@Suite internal struct CustomFrontMatterTests {
  /// A front matter with none of `Newsletter.FrontMatter`'s field names.
  internal struct CustomFrontMatter: Encodable {
    internal let headline: String
    internal let publishedAt: String
    internal let tags: [String]
  }

  /// Carries configuration (`tags`), which the `ContentType` path cannot do
  /// because it default-constructs its translator.
  internal struct CustomTranslator: Contribute.FrontMatterTranslator {
    internal typealias SourceType = Newsletter.Source
    internal typealias FrontMatterType = CustomFrontMatter

    internal let tags: [String]

    internal init() {
      tags = []
    }

    internal init(tags: [String]) {
      self.tags = tags
    }

    internal func frontMatter(from source: Newsletter.Source) -> CustomFrontMatter {
      CustomFrontMatter(
        headline: source.title,
        publishedAt: YAML.dateFormatter.string(from: source.date),
        tags: tags
      )
    }
  }

  private static let fallbackImage: URL = {
    guard let url = URL(string: "https://example.com/fallback.png") else {
      preconditionFailure("Invalid fallback image URL")
    }
    return url
  }()

  private static func makeSource() throws -> Newsletter.Source {
    let email = Fixtures.email(
      subject: "Issue #118",
      daysAfterEpoch: 100,
      body: "<!-- buttondown-editor-mode: plaintext -->\n\n# Hello world"
    )
    return try Newsletter.Source(
      email: email,
      issueNo: 118,
      slug: "issue-118",
      featuredImageFallback: Self.fallbackImage
    )
  }

  /// The custom translator's schema reaches disk: its keys are present, the
  /// default schema's keys are gone, and the body still copies through.
  @Test internal func writesCustomFrontMatterToDisk() throws {
    let source = try Self.makeSource()
    let directory = FileManager.default.temporaryDirectory
      .appendingPathComponent("ContributeButtondownCustomFM-\(source.buttondownID)")
    try FileManager.default.createDirectory(
      at: directory, withIntermediateDirectories: true
    )
    defer { try? FileManager.default.removeItem(at: directory) }

    try Newsletter.write(
      from: [source],
      atContentPathURL: directory,
      fileNameWithoutExtension: { "\($0.issueNo)-\($0.slug)" },
      using: { _ in
        Issue.record("Buttondown Markdown must not go through the HTML converter")
        return "converted"
      },
      translatedBy: CustomTranslator(tags: ["newsletter", "swift"])
    )

    let written = directory.appendingPathComponent("118-issue-118.md")
    let content = try String(contentsOf: written, encoding: .utf8)

    // The custom schema is what landed.
    #expect(content.contains("headline:"))
    #expect(content.contains("publishedAt:"))
    #expect(content.contains("- newsletter"))
    #expect(content.contains("- swift"))

    // The default schema's distinctive keys are absent.
    #expect(!content.contains("issueNo:"))
    #expect(!content.contains("buttondownID:"))
    #expect(!content.contains("longArchiveURL:"))

    // The body still copies through, marker stripped.
    #expect(content.contains("# Hello world"))
    #expect(!content.contains("buttondown-editor-mode"))
  }

  /// The default path is unchanged by the addition of the custom overload.
  @Test internal func defaultWriteStillEmitsTheDefaultSchema() throws {
    let source = try Self.makeSource()
    let directory = FileManager.default.temporaryDirectory
      .appendingPathComponent("ContributeButtondownDefaultFM-\(source.buttondownID)")
    try FileManager.default.createDirectory(
      at: directory, withIntermediateDirectories: true
    )
    defer { try? FileManager.default.removeItem(at: directory) }

    try Newsletter.write(
      from: [source],
      atContentPathURL: directory,
      fileNameWithoutExtension: { "\($0.issueNo)-\($0.slug)" },
      using: { _ in "converted" }
    )

    let written = directory.appendingPathComponent("118-issue-118.md")
    let content = try String(contentsOf: written, encoding: .utf8)

    #expect(content.contains("issueNo: 118"))
    #expect(content.contains("buttondownID:"))
    #expect(content.contains("longArchiveURL:"))
    #expect(!content.contains("headline:"))
  }

  /// `FrontMatter` is constructible outside the package, so a consumer can build
  /// one directly (e.g. to wrap or extend it) rather than only receive one.
  @Test private func frontMatterIsConstructibleByConsumers() throws {
    let image = try #require(URL(string: "https://example.com/cover.png"))
    let archive = try #require(URL(string: "https://example.com/archive/118/"))

    let frontMatter = Newsletter.FrontMatter(
      issueNo: 118,
      buttondownID: "em_abc",
      featuredImage: image,
      longArchiveURL: archive,
      title: "Issue #118",
      date: "2026-07-26 12:00",
      description: "The 118th issue."
    )

    #expect(frontMatter.issueNo == 118)
    #expect(frontMatter.title == "Issue #118")
  }
}
