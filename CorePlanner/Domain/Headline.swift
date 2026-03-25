// ===-----------------------------------------------------------------------===
// Copyright © 2026 Jean Silva
//
// This file is part of the Pragma open-source project.
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program. If not, see https://www.gnu.org/licenses.
// ===-----------------------------------------------------------------------===

/// Components of an ``Idea`` by which such ``Idea`` may be described with
/// different levels of detail. Serves as an explanation for what the ``Idea``
/// represents and/or how to achieve its objective.
public struct Headline: Sendable {
  /// Main, general, non-blank description.
  let title: String

  /// Secondary, detailed explanation related to the contents of the ``title``.
  /// May be blank.
  let summary: String

  /// Initializes a ``Headline`` with a title and a summary which have already
  /// undergone normalization.
  ///
  /// - Parameters:
  ///   - title: Main, general, non-blank description.
  ///   - summary: Secondary, detailed explanation related to the contents of
  ///     the ``title``. May be blank.
  private init(title: String, summary: String) {
    self.title = title
    self.summary = summary
  }

  /// Produces a ``Headline`` from a title and a summary suggested by the user,
  /// normalizing them.
  ///
  /// Normalization consists may consist of two steps:
  ///
  /// 1. Verification of whether the title has been populated with
  ///    non-whitespace characters; if not, it is blank, and this function will
  ///    terminate the program. This step is performed only in `-Onone` builds.
  /// 2. Removal of leading and trailing whitespaces from the summary, which, as
  ///    opposed to the title, may be blank.
  ///
  /// - Returns: A ``Headline`` with the given `title` and `summary` normalized.
  public static func from(title: String, summary: String) -> Self {
    precondition(!title.isBlank, "Title cannot be blank.")
    var title = title
    var summary = summary
    title.trim(.whitespacesAndNewlines)
    summary.trim(.whitespacesAndNewlines)
    return .init(title: title, summary: summary)
  }
}

extension String {
  /// Whether this ``String`` is empty or contains only whitespace or newlines.
  fileprivate var isBlank: Bool {
    isEmpty
      || allSatisfy { character in character.isNewline || character.isWhitespace
      }
  }

  /// Removes prefixes and suffixes which are a subset of the given set.
  ///
  /// - Parameter characters: Set of characters which should be removed from
  ///   both extremes of this ``String``.
  fileprivate mutating func trim(_ characters: CharacterSet) {
    guard !isEmpty else { return }
    var trimmingIndices = Array(indices)
    var trimmableCount: Int {
      trimmingIndices.count(while: { trimmingIndex in
        !characters.isDisjoint(
          with: .init(charactersIn: .init(self[trimmingIndex]))
        )
      })
    }
    let leadingTrimmableCount = trimmableCount
    if leadingTrimmableCount > 0 {
      removeSubrange(
        startIndex..<index(startIndex, offsetBy: leadingTrimmableCount)
      )
      guard !isEmpty else { return }
    }
    trimmingIndices = .init(indices)
    trimmingIndices.reverse()
    let trailingTrimmableCount = trimmableCount
    guard trailingTrimmableCount > 0 else { return }
    removeSubrange(
      index(endIndex, offsetBy: -trailingTrimmableCount)..<endIndex
    )
  }
}

extension Sequence {
  /// Counts how many elements consecutively match the `predicate`, starting
  /// from the first one.
  ///
  /// - Complexity: O(*n*), where *n* is the amount of elements in this
  ///   sequence.
  /// - Parameter predicate: Condition to be satisfied by an element for
  ///   determining whether that which succeeds it may be counted. Returning
  ///   `false` denotes that the return of ``count(while:)`` will be the amount
  ///   of elements for which this predicate has yielded `true` until this one.
  fileprivate func count(while predicate: (Element) -> Bool) -> Int {
    var count = 0
    for element in self {
      guard predicate(element) else { break }
      count += 1
    }
    return count
  }
}
