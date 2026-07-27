//
//  IssueNumbering.swift
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

/// How an explicit issue number is recognized in an email subject.
///
/// Newsletter archives are numbered; Buttondown subjects are not reliably. This
/// type describes the marker your subjects use, so
/// ``Newsletter/newIssues(from:continuingFrom:existingIssueNumbers:existingSlugs:slug:numbering:)``
/// can honor a number that is already written into the subject instead of
/// assigning a sequential one.
///
/// ``default`` recognizes the common `Issue N` / `Issue #N` form. Supply your
/// own pattern when your subjects number issues differently:
///
/// ```swift
/// // Subjects like "Weekly #42 — what shipped"
/// let numbering = try IssueNumbering(subjectPattern: #"(?i)weekly\s*#?\s*(\d+)"#)
/// ```
///
/// The pattern must contain a capture group; the **first** capture group of the
/// **first** match is read as the issue number. A subject with no match carries
/// no explicit number and falls back to sequential numbering.
public struct IssueNumbering: Sendable {
  /// Recognizes the `Issue N` / `Issue #N` marker, case-insensitively.
  ///
  /// Matches `"Issue 118"`, `"Issue #118"`, and the `"… - Issue #118 - …"` form.
  /// Numbers that don't follow the word `Issue` — a version like
  /// `"Bushel v2.3.0"`, say — are deliberately ignored, so those emails fall
  /// back to sequential numbering.
  public static let `default`: IssueNumbering = {
    do {
      return try IssueNumbering(subjectPattern: #"(?i)issue\s*#?\s*(\d+)"#)
    } catch {
      preconditionFailure("Invalid default subject pattern: \(error)")
    }
  }()

  private let regex: NSRegularExpression

  /// The regular-expression pattern used to recognize an issue number.
  public var subjectPattern: String { regex.pattern }

  /// Creates a numbering scheme from a regular-expression pattern.
  ///
  /// - Parameter subjectPattern: A pattern whose first capture group captures
  ///   the issue number's digits.
  /// - Throws: An error if `subjectPattern` is not a valid regular expression, or
  ///   if it has no capture group for the issue number.
  public init(subjectPattern: String) throws {
    let compiled = try NSRegularExpression(pattern: subjectPattern, options: [])
    guard compiled.numberOfCaptureGroups >= 1 else {
      throw IssueNumberingError.missingCaptureGroup(pattern: subjectPattern)
    }
    regex = compiled
  }

  /// Parses an explicit issue number from an email subject, if present.
  ///
  /// - Parameter subject: The email subject line.
  /// - Returns: The captured number, or `nil` when the subject carries no
  ///   recognizable marker.
  public func issueNumber(fromSubject subject: String) -> Int? {
    let range = NSRange(subject.startIndex..<subject.endIndex, in: subject)
    guard
      let match = regex.firstMatch(in: subject, options: [], range: range),
      match.numberOfRanges > 1,
      let numberRange = Range(match.range(at: 1), in: subject),
      let issueNumber = Int(subject[numberRange])
    else {
      return nil
    }
    return issueNumber
  }
}
