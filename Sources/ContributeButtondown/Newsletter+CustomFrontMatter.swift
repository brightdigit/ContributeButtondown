//
//  Newsletter+CustomFrontMatter.swift
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

extension Newsletter {
  /// Writes issues using a front matter of your own, rather than
  /// ``Newsletter/FrontMatter``.
  ///
  /// ``Newsletter/FrontMatter`` is the shape brightdigit.com's newsletter section
  /// reads. It is a sensible default, not a requirement — the front matter is any
  /// `Encodable`, so a site with a different schema supplies its own translator
  /// here instead of reimplementing the importer.
  ///
  /// ```swift
  /// struct MyFrontMatter: Encodable {
  ///   let title: String
  ///   let publishedAt: String
  ///   let tags: [String]
  /// }
  ///
  /// struct MyTranslator: Contribute.FrontMatterTranslator {
  ///   let tags: [String]                     // per-site config lives here
  ///   init() { tags = [] }
  ///   init(tags: [String]) { self.tags = tags }
  ///
  ///   func frontMatter(from source: Newsletter.Source) -> MyFrontMatter {
  ///     MyFrontMatter(
  ///       title: source.title,
  ///       publishedAt: YAML.dateFormatter.string(from: source.date),
  ///       tags: tags
  ///     )
  ///   }
  /// }
  ///
  /// try Newsletter.write(
  ///   from: sources,
  ///   atContentPathURL: contentPathURL,
  ///   fileNameWithoutExtension: { "\($0.issueNo)-\($0.slug)" },
  ///   using: htmlToMarkdown,
  ///   translatedBy: MyTranslator(tags: ["newsletter"])
  /// )
  /// ```
  ///
  /// Unlike the `ContentType` path, which default-constructs its translator, this
  /// takes a translator **instance** — so a translator may carry whatever
  /// configuration the site needs.
  ///
  /// - Parameters:
  ///   - sources: The resolved issues to write.
  ///   - contentPathURL: The directory to write into.
  ///   - fileNameWithoutExtension: Produces each issue's file name, without the
  ///     extension.
  ///   - htmlToMarkdown: Converts HTML to Markdown. Unused by
  ///     ``Newsletter/MarkdownExtractor`` (Buttondown bodies are already
  ///     Markdown), but required by the pipeline.
  ///   - translator: Produces the front matter for each issue.
  ///   - options: Content-builder options, e.g. overwrite behavior.
  /// - Throws: An error if the issues could not be written.
  public static func write<TranslatorType: Contribute.FrontMatterTranslator>(
    from sources: [Source],
    atContentPathURL contentPathURL: URL,
    fileNameWithoutExtension: @escaping (Source) -> String,
    using htmlToMarkdown: @escaping (String) throws -> String,
    translatedBy translator: TranslatorType,
    options: MarkdownContentBuilderOptions = []
  ) throws where TranslatorType.SourceType == Source {
    let builder = MarkdownContentYAMLBuilder(
      frontMatterExporter: FrontMatterYAMLExporter(translator: translator),
      markdownExtractor: MarkdownExtractor()
    )
    try builder.write(
      from: sources,
      atContentPathURL: contentPathURL,
      basedOn: FileNameGenerator(fileNameWithoutExtension),
      using: htmlToMarkdown,
      options: options
    )
  }
}
