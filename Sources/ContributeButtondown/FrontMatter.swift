//
//  FrontMatter.swift
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

import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Newsletter {
  /// The YAML front matter emitted for a Buttondown newsletter issue.
  ///
  /// The field set mirrors what `Sources/BrightDigitSite`'s `NewsletterItem`
  /// reads: `issueNo`, `title`, `date`, `description`, `featuredImage`
  /// (required by `ItemMetadata`), and `longArchiveURL` (the newsletter's
  /// redirect target). ``buttondownID`` is retained for provenance/reversibility
  /// and is ignored by the site (unknown metadata keys are tolerated), the same
  /// way the Mailchimp importer retained `campaignID`.
  public struct FrontMatter: Codable, Equatable, Sendable {
    /// The assigned issue number.
    public let issueNo: Int
    /// The originating Buttondown email id.
    public let buttondownID: String
    /// The featured/preview image URL.
    public let featuredImage: URL
    /// The canonical archive URL of the issue.
    public let longArchiveURL: URL
    /// The issue title (email subject).
    public let title: String
    /// The published date, pre-formatted via ``Contribute/YAML/dateFormatter``.
    public let date: String
    /// The issue description.
    public let description: String
  }
}
