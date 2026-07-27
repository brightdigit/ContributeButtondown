//
//  FrontMatter.swift
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

import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Newsletter {
  /// The YAML front matter emitted for a Buttondown newsletter issue.
  ///
  /// This is a **reasonable default, not a fixed contract.** The field set is the
  /// one brightdigit.com's newsletter section reads: `issueNo`, `title`, `date`,
  /// `description`, `featuredImage`, and `longArchiveURL` (the newsletter's
  /// redirect target). ``buttondownID`` is retained for provenance and is ignored
  /// by consumers that don't know it — unknown YAML keys are tolerated.
  ///
  /// If your site needs a different shape, you are not stuck with this type. Any
  /// `Encodable` will do: define your own front matter and a translator that
  /// produces it, then write with
  /// ``Newsletter/write(from:atContentPathURL:fileNameWithoutExtension:using:translatedBy:options:)``.
  /// See ``Newsletter/FrontMatterTranslator`` for the default translator.
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

    /// Memberwise initializer.
    ///
    /// - Parameters:
    ///   - issueNo: The assigned issue number.
    ///   - buttondownID: The originating Buttondown email id.
    ///   - featuredImage: The featured/preview image URL.
    ///   - longArchiveURL: The canonical archive URL of the issue.
    ///   - title: The issue title.
    ///   - date: The published date, pre-formatted for YAML.
    ///   - description: The issue description.
    public init(
      issueNo: Int,
      buttondownID: String,
      featuredImage: URL,
      longArchiveURL: URL,
      title: String,
      date: String,
      description: String
    ) {
      self.issueNo = issueNo
      self.buttondownID = buttondownID
      self.featuredImage = featuredImage
      self.longArchiveURL = longArchiveURL
      self.title = title
      self.date = date
      self.description = description
    }
  }
}
