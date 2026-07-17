//
//  Newsletter+IssueNumbering.swift
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
import Foundation

extension Newsletter {
  /// A Buttondown email paired with the issue number assigned to it.
  public struct NumberedEmail: Sendable, Equatable {
    /// The source Buttondown email.
    public let email: Email
    /// The issue number assigned by
    /// ``Newsletter/assignIssueNumbers(to:continuingFrom:)``.
    public let issueNo: Int

    /// Memberwise initializer.
    public init(email: Email, issueNo: Int) {
      self.email = email
      self.issueNo = issueNo
    }
  }

  // Captures the issue number that follows the word "Issue" (case-insensitive),
  // with an optional `#`: matches "Issue 118", "Issue #118", and the
  // "… - Issue #118 - …" form the BrightDigit newsletter subjects use. Numbers
  // that don't follow "Issue" (e.g. a version like "Bushel v2.3.0") are
  // deliberately ignored, so those emails fall back to sequential numbering.
  private static let issueNoRegexPatternString = #"(?i)issue\s*#?\s*(\d+)"#

  private static let issueNoRegex: NSRegularExpression = {
    do {
      return try NSRegularExpression(pattern: issueNoRegexPatternString, options: [])
    } catch {
      preconditionFailure("Invalid issueNoRegex pattern: \(error)")
    }
  }()

  /// Parses an explicit issue number from an email subject, if present.
  ///
  /// - Parameter subject: The email subject line.
  /// - Returns: The number following "Issue" (optionally `#`), or `nil` when the
  ///   subject carries no such marker.
  public static func parseIssueNumber(fromSubject subject: String) -> Int? {
    let range = NSRange(subject.startIndex..<subject.endIndex, in: subject)
    guard
      let match = issueNoRegex.firstMatch(in: subject, options: [], range: range),
      match.numberOfRanges > 1,
      let numberRange = Range(match.range(at: 1), in: subject),
      let issueNumber = Int(subject[numberRange])
    else {
      return nil
    }
    return issueNumber
  }

  /// Assigns an issue number to each email, oldest-first.
  ///
  /// Numbering needs global ordering, so this sorts the emails by
  /// `creationDate` ascending and walks them once. An email whose subject
  /// carries an explicit "Issue N" marker keeps that number; an unnumbered email
  /// takes the next sequential number, continuing from `localMaxIssueNo` and any
  /// higher explicit number already seen. This continues the local archive
  /// (which ends at issue 117) as 118, 119, … while honoring explicit numbers
  /// when Buttondown provides them.
  ///
  /// - Parameters:
  ///   - emails: The Buttondown emails to number (typically the `.sent` ones).
  ///   - localMaxIssueNo: The highest issue number already present locally.
  /// - Returns: One ``NumberedEmail`` per input email, in oldest-first order.
  public static func assignIssueNumbers(
    to emails: [Email],
    continuingFrom localMaxIssueNo: Int
  ) -> [NumberedEmail] {
    let ordered = emails.sorted { $0.creationDate < $1.creationDate }
    var maxAssigned = localMaxIssueNo
    var result: [NumberedEmail] = []
    for email in ordered {
      let issueNo: Int
      if let explicit = parseIssueNumber(fromSubject: email.subject) {
        issueNo = explicit
      } else {
        issueNo = maxAssigned + 1
      }
      maxAssigned = max(maxAssigned, issueNo)
      result.append(NumberedEmail(email: email, issueNo: issueNo))
    }
    return result
  }

  /// Numbers the emails, then keeps only those whose issue number is not already
  /// present locally — the new issues to import (118+ for the current archive).
  ///
  /// - Parameters:
  ///   - emails: The Buttondown emails to number.
  ///   - localMaxIssueNo: The highest issue number already present locally.
  ///   - existingIssueNumbers: Issue numbers already on disk, to skip.
  /// - Returns: The numbered emails not already present, in oldest-first order.
  public static func newIssues(
    from emails: [Email],
    continuingFrom localMaxIssueNo: Int,
    existingIssueNumbers: Set<Int>
  ) -> [NumberedEmail] {
    assignIssueNumbers(to: emails, continuingFrom: localMaxIssueNo)
      .filter { !existingIssueNumbers.contains($0.issueNo) }
  }
}
