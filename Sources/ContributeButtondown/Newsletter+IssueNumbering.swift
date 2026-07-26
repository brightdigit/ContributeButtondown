//
//  Newsletter+IssueNumbering.swift
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

import ButtondownKit
import Foundation

extension Newsletter {
  /// A Buttondown email paired with the issue number assigned to it.
  public struct NumberedEmail: Sendable, Equatable {
    /// The source Buttondown email.
    public let email: Email
    /// The issue number assigned by
    /// ``Newsletter/assignIssueNumbers(to:continuingFrom:numbering:)``.
    public let issueNo: Int

    /// Memberwise initializer.
    public init(email: Email, issueNo: Int) {
      self.email = email
      self.issueNo = issueNo
    }
  }

  /// Parses an explicit issue number from an email subject, if present.
  ///
  /// - Parameters:
  ///   - subject: The email subject line.
  ///   - numbering: How an issue number is recognized in a subject. Defaults to
  ///     ``IssueNumbering/default``, the `Issue N` / `Issue #N` form.
  /// - Returns: The captured number, or `nil` when the subject carries no
  ///   recognizable marker.
  public static func parseIssueNumber(
    fromSubject subject: String,
    numbering: IssueNumbering = .default
  ) -> Int? {
    numbering.issueNumber(fromSubject: subject)
  }

  /// Assigns an issue number to each email, oldest-first.
  ///
  /// Numbering needs global ordering, so this sorts the emails by
  /// `creationDate` ascending and walks them once. An email whose subject
  /// carries an explicit marker keeps that number; an unnumbered email takes the
  /// next sequential number, continuing from `localMaxIssueNo` and any higher
  /// explicit number already seen. An archive whose highest issue is N therefore
  /// continues as N+1, N+2, … while explicit numbers are honored wherever the
  /// subjects provide them.
  ///
  /// - Parameters:
  ///   - emails: The Buttondown emails to number (typically the `.sent` ones).
  ///   - localMaxIssueNo: The highest issue number already present locally.
  ///   - numbering: How an issue number is recognized in a subject. Defaults to
  ///     ``IssueNumbering/default``, the `Issue N` / `Issue #N` form.
  /// - Returns: One ``NumberedEmail`` per input email, in oldest-first order.
  public static func assignIssueNumbers(
    to emails: [Email],
    continuingFrom localMaxIssueNo: Int,
    numbering: IssueNumbering = .default
  ) -> [NumberedEmail] {
    let ordered = emails.sorted { $0.creationDate < $1.creationDate }
    var maxAssigned = localMaxIssueNo
    var result: [NumberedEmail] = []
    for email in ordered {
      let issueNo: Int
      if let explicit = numbering.issueNumber(fromSubject: email.subject) {
        issueNo = explicit
      } else {
        issueNo = maxAssigned + 1
      }
      maxAssigned = max(maxAssigned, issueNo)
      result.append(NumberedEmail(email: email, issueNo: issueNo))
    }
    return result
  }

  /// Filters out the emails already present locally, then numbers the rest —
  /// the new issues to import.
  ///
  /// Filtering happens **before** numbering, which is what makes repeated
  /// imports idempotent. An unnumbered sent email is assigned the next
  /// sequential number, and that number is derived from `localMaxIssueNo`, which
  /// grows as issues are written. Numbering first and filtering by number (the
  /// old behavior) therefore re-imported the same email under a fresh number on
  /// every run. Instead an email is treated as already present when either its
  /// explicit subject number is in `existingIssueNumbers`, or its `slug` — which
  /// is derived from the stable subject and encoded in the `NNN-slug` file name —
  /// is in `existingSlugs`. Remaining emails are numbered from `localMaxIssueNo`,
  /// so their numbers stay contiguous.
  ///
  /// - Parameters:
  ///   - emails: The Buttondown emails to consider (typically the `.sent` ones).
  ///   - localMaxIssueNo: The highest issue number already present locally.
  ///   - existingIssueNumbers: Explicit issue numbers already on disk, to skip.
  ///   - existingSlugs: Slugs already on disk (from `NNN-slug.md` names), to skip.
  ///   - slug: Derives an email's slug the same way the writer names its file.
  ///   - numbering: How an issue number is recognized in a subject. Defaults to
  ///     ``IssueNumbering/default``, the `Issue N` / `Issue #N` form.
  /// - Returns: The numbered new issues, in oldest-first order.
  public static func newIssues(
    from emails: [Email],
    continuingFrom localMaxIssueNo: Int,
    existingIssueNumbers: Set<Int>,
    existingSlugs: Set<String>,
    slug: (Email) -> String,
    numbering: IssueNumbering = .default
  ) -> [NumberedEmail] {
    let fresh = emails.filter { email in
      if let explicit = numbering.issueNumber(fromSubject: email.subject),
        existingIssueNumbers.contains(explicit)
      {
        return false
      }
      return !existingSlugs.contains(slug(email))
    }
    return assignIssueNumbers(
      to: fresh,
      continuingFrom: localMaxIssueNo,
      numbering: numbering
    )
  }
}
