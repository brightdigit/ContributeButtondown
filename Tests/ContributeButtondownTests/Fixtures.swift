//
//  Fixtures.swift
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

/// Constructed ``ButtondownKit/Email`` values for offline tests (no network).
internal enum Fixtures {
  /// Builds a sent email `daysAfterEpoch` days after the reference date, so
  /// tests can control creation-date ordering deterministically.
  internal static func email(
    subject: String,
    daysAfterEpoch: Int,
    id: String = UUID().uuidString,
    body: String = "<p>Body</p>",
    absoluteURL: String = "https://buttondown.com/brightdigit/archive/example/",
    description: String = "An example issue.",
    image: String = ""
  ) -> Email {
    let date = Date(timeIntervalSince1970: TimeInterval(daysAfterEpoch) * 86_400)
    return Email(
      id: id,
      subject: subject,
      body: body,
      status: .sent,
      creationDate: date,
      modificationDate: date,
      absoluteURL: absoluteURL,
      description: description,
      image: image
    )
  }
}
