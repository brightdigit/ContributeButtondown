//
//  Source.swift
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

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Newsletter {
  /// A fully-resolved Buttondown newsletter issue: the email metadata plus an
  /// assigned issue number and a slug, ready to be written to Markdown.
  ///
  public struct Source: Sendable {
    /// The URL-safe slug used for the file name (`NNN-slug.md`).
    public let slug: String
    /// The assigned issue number (see ``IssueNumbering``).
    public let issueNo: Int
    /// The Buttondown email id (a TypeID).
    public let buttondownID: String
    /// The canonical archive URL of the email on the newsletter's web archive.
    public let longArchiveURL: URL
    /// The preview/featured image URL (resolved to a fallback when the email
    /// supplied none, so the site's required `featuredImage` is always present).
    public let featuredImageURL: URL
    /// The email subject line, used as the front-matter `title`.
    public let title: String
    /// The email's human-readable description, used as the `description`.
    public let description: String
    /// The email's creation date, used as the published `date`.
    public let date: Date
    /// The email body Markdown, copied directly by the extractor.
    public let markdown: String

    /// Memberwise initializer.
    public init(
      slug: String,
      issueNo: Int,
      buttondownID: String,
      longArchiveURL: URL,
      featuredImageURL: URL,
      title: String,
      description: String,
      date: Date,
      markdown: String
    ) {
      self.slug = slug
      self.issueNo = issueNo
      self.buttondownID = buttondownID
      self.longArchiveURL = longArchiveURL
      self.featuredImageURL = featuredImageURL
      self.title = title
      self.description = description
      self.date = date
      self.markdown = markdown
    }
  }
}

extension Newsletter.Source {
  /// Builds a ``Newsletter/Source`` from a Buttondown ``ButtondownKit/Email``.
  ///
  /// The email's Markdown `body` is carried verbatim. `absoluteURL` becomes the
  /// archive link; an empty `image`
  /// falls back to `featuredImageFallback`.
  ///
  /// - Parameters:
  ///   - email: The Buttondown email to import.
  ///   - issueNo: The issue number assigned to this email.
  ///   - slug: The URL-safe slug for the file name.
  ///   - featuredImageFallback: The image URL to use when the email has none.
  /// - Throws: ``ButtondownImportError/malformedArchiveURL`` if `absoluteURL`
  ///   cannot be parsed into a `URL`.
  public init(
    email: Email,
    issueNo: Int,
    slug: String,
    featuredImageFallback: URL
  ) throws {
    guard let longArchiveURL = URL(string: email.absoluteURL) else {
      throw ButtondownImportError.malformedArchiveURL(
        emailID: email.id, value: email.absoluteURL
      )
    }
    let featuredImageURL: URL
    if email.image.isEmpty {
      featuredImageURL = featuredImageFallback
    } else {
      featuredImageURL = URL(string: email.image) ?? featuredImageFallback
    }
    self.init(
      slug: slug,
      issueNo: issueNo,
      buttondownID: email.id,
      longArchiveURL: longArchiveURL,
      featuredImageURL: featuredImageURL,
      title: email.subject,
      description: email.description,
      date: email.creationDate,
      markdown: email.body
    )
  }
}
