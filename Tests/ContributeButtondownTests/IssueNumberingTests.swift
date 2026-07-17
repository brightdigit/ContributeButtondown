//
//  IssueNumberingTests.swift
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
import Testing

@testable import ContributeButtondown

/// Exercises subject parsing, sequential numbering, and the skip-existing logic.
@Suite internal struct IssueNumberingTests {
  /// "Issue N" and "Issue #N" parse out the number.
  ///
  /// This includes the interior "- Issue #N -" form. Version strings and empty
  /// subjects do not parse as issue numbers.
  @Test internal func parseIssueNumberVariants() {
    #expect(Newsletter.parseIssueNumber(fromSubject: "Issue 118") == 118)
    #expect(Newsletter.parseIssueNumber(fromSubject: "Issue #119") == 119)
    #expect(
      Newsletter.parseIssueNumber(
        fromSubject: "BrightDigit Newsletter - Issue #120 - 26.01.15"
      ) == 120
    )
    #expect(
      Newsletter.parseIssueNumber(fromSubject: "issue   #121  extra") == 121
    )
    #expect(Newsletter.parseIssueNumber(fromSubject: "Bushel v2.3.0 released") == nil)
    #expect(Newsletter.parseIssueNumber(fromSubject: "Introducing swift-build") == nil)
    #expect(Newsletter.parseIssueNumber(fromSubject: "") == nil)
  }

  /// Explicit subject numbers win; unnumbered emails take the next sequential
  /// number continuing from the local max — assigned oldest-first regardless of
  /// input order.
  @Test internal func assignsNumbersOldestFirst() {
    let emails = [
      Fixtures.email(subject: "Unnumbered launch", daysAfterEpoch: 3),
      Fixtures.email(subject: "Issue #118", daysAfterEpoch: 1),
      Fixtures.email(subject: "Another unnumbered", daysAfterEpoch: 2),
    ]
    let numbered = Newsletter.assignIssueNumbers(to: emails, continuingFrom: 117)
    // Ordered oldest-first: #118 (explicit), then 119, 120 sequential.
    #expect(numbered.map(\.issueNo) == [118, 119, 120])
    #expect(
      numbered.map(\.email.subject) == [
        "Issue #118", "Another unnumbered", "Unnumbered launch",
      ]
    )
  }

  /// An explicit number higher than the running max advances the sequential
  /// counter, so a later unnumbered email continues past it.
  @Test internal func explicitNumberAdvancesSequentialCounter() {
    let emails = [
      Fixtures.email(subject: "Issue #125", daysAfterEpoch: 1),
      Fixtures.email(subject: "No number here", daysAfterEpoch: 2),
    ]
    let numbered = Newsletter.assignIssueNumbers(to: emails, continuingFrom: 117)
    #expect(numbered.map(\.issueNo) == [125, 126])
  }

  /// `newIssues` drops issue numbers already present locally, keeping only the
  /// genuinely new ones.
  @Test internal func newIssuesSkipsExisting() {
    let emails = [
      Fixtures.email(subject: "Issue #117", daysAfterEpoch: 1),
      Fixtures.email(subject: "Issue #118", daysAfterEpoch: 2),
      Fixtures.email(subject: "Issue #119", daysAfterEpoch: 3),
    ]
    let result = Newsletter.newIssues(
      from: emails,
      continuingFrom: 117,
      existingIssueNumbers: [117]
    )
    #expect(result.map(\.issueNo) == [118, 119])
  }

  /// With no explicit numbers at all, the whole batch is numbered sequentially
  /// from the local max.
  @Test internal func allUnnumberedSequentialFromMax() {
    let emails = [
      Fixtures.email(subject: "One", daysAfterEpoch: 1),
      Fixtures.email(subject: "Two", daysAfterEpoch: 2),
    ]
    let numbered = Newsletter.assignIssueNumbers(to: emails, continuingFrom: 117)
    #expect(numbered.map(\.issueNo) == [118, 119])
  }
}
