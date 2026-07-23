//
//  MarkdownExtractor.swift
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

extension Newsletter {
  /// Copies a Buttondown plaintext-editor body directly into site content.
  public struct MarkdownExtractor: Contribute.MarkdownExtractor {
    /// The resolved newsletter issue whose body is copied through.
    public typealias SourceType = Source

    private static let editorModeMarker =
      "<!-- buttondown-editor-mode: plaintext -->"

    /// Creates an extractor.
    public init() {}

    /// Returns the issue's Markdown body.
    ///
    /// Buttondown's plaintext editor already stores Markdown, so the body is
    /// copied verbatim and the HTML-to-Markdown conversion is unused. The
    /// leading `<!-- buttondown-editor-mode: plaintext -->` marker, and the
    /// newlines that follow it, are stripped.
    ///
    /// - Parameters:
    ///   - source: The resolved newsletter issue.
    ///   - htmlToMarkdown: The HTML-to-Markdown conversion supplied by the
    ///     pipeline. Unused here, because the body is already Markdown.
    /// - Returns: The issue body as Markdown.
    /// - Throws: Never; the body is copied without conversion.
    public func markdown(
      from source: Source,
      using htmlToMarkdown: @escaping (String) throws -> String
    ) throws -> String {
      guard source.markdown.hasPrefix(Self.editorModeMarker) else {
        return source.markdown
      }

      let body = source.markdown.dropFirst(Self.editorModeMarker.count)
      return String(body.drop(while: { $0.isNewline }))
    }
  }
}
