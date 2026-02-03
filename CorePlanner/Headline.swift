// ===-------------------------------------------------------------------------------------------===
// Copyright © 2026 Jean Silva
//
// This file is part of the Pragma open-source project.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
// even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If
// not, see https://www.gnu.org/licenses.
// ===-------------------------------------------------------------------------------------------===

// MARK: - Backwards compatibility

/// ``Headlined`` which allows for asynchronous modifications of its ``Headlined/title`` and
/// ``Headlined/summary``.
@available(*, deprecated, message: "Headline should be implemented manually.")
public protocol Headlineable: Headlined {
  /// Changes the ``Headlined/title``.
  ///
  /// - Parameter newTitle: Title by which the current one will be replaced.
  mutating func setTitle(to newTitle: String) async throws

  /// Changes the ``Headlined/abstract``.
  ///
  /// - Parameter newAbstract: Abstract by which the current one will be replaced.
  mutating func setAbstract(to newAbstract: String) async throws
}

/// Structs or classes conforming to this protocol are presentable by a general, short summary;
/// and a more descriptive, longer one. These may be mutable in case such structs or classes also
/// conform to ``Headlineable``.
@available(*, deprecated, message: "Title and abstract should be implemented manually.")
public protocol Headlined: Comparable, Hashable, Identifiable, SendableMetatype {
  /// Main, general, non-blank summary.
  var title: String { get }

  /// Secondary, detailed explanation related to the contents of the ``title``. May be blank.
  var abstract: String { get }
}

extension Headlined where Self: Comparable {
  /// Compares the ``title`` and the ``summary`` of both objects, allowing for them to be sorted
  /// alphabetically in an implementation of the ``<(_:_:)`` function. Should be called and have its
  /// return considered by every implementation of this type when a result of the latter function is
  /// given.
  ///
  /// - Parameter other: Right-hand-side of the comparison.
  public func isLesser(than other: Self) -> Bool {
    title[title.startIndex] < other.title[other.title.startIndex]
      && abstract[abstract.startIndex] < other.abstract[other.abstract.startIndex]
  }

  public static func < (lhs: Self, rhs: Self) -> Bool { lhs.isLesser(than: rhs) }
}

extension Headlined where Self: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
}

// MARK: - Normalization

/// Ensures that a title is not empty and trims it.
///
/// This function *must* be called upon updates of the title, and the backing property *must* be set
/// to the resulting value.
///
/// - Parameters:
///   - title: Title suggested for a headline.
public func normalize(title: inout String) {
  precondition(!title.isBlank, "A title cannot be blank.")
  title.trim(.whitespacesAndNewlines)
}

/// Trims an ``abstract``.
///
/// This function *must* be called upon updates of the abstract, and the backing property *must* be
/// set to the resulting value.
///
/// - Parameters:
///   - abstract: Abstract suggested for a headline.
public func normalize(abstract: inout String) {
  abstract.trim(.whitespacesAndNewlines)
}

extension String {
  /// Whether this ``String`` is empty or contains only whitespace or newlines.
  fileprivate var isBlank: Bool {
    isEmpty || allSatisfy { character in character.isNewline || character.isWhitespace }
  }

  /// Removes prefixes and suffixes which are a subset of the given set.
  ///
  /// - Parameter characters: Set of characters which should be removed from both extremes of this
  ///   ``String``.
  fileprivate mutating func trim(_ characters: CharacterSet) {
    guard !isEmpty else { return }
    var trimmingIndices = Array(indices)
    var trimmableCount: Int {
      trimmingIndices.count(while: { trimmingIndex in
        !characters.isDisjoint(with: .init(charactersIn: .init(self[trimmingIndex])))
      })
    }
    let leadingTrimmableCount = trimmableCount
    if leadingTrimmableCount > 0 {
      removeSubrange(startIndex..<index(startIndex, offsetBy: leadingTrimmableCount))
      guard !isEmpty else { return }
    }
    trimmingIndices = .init(indices)
    trimmingIndices.reverse()
    let trailingTrimmableCount = trimmableCount
    guard trailingTrimmableCount > 0 else { return }
    removeSubrange(index(endIndex, offsetBy: -trailingTrimmableCount)..<endIndex)
  }
}

extension Sequence {
  /// Counts how many elements consecutively match the `predicate`, starting from the first one.
  ///
  /// - Complexity: O(*n*), where *n* is the amount of elements in this sequence.
  /// - Parameter predicate: Condition to be satisfied by an element for determining whether that
  ///   which succeeds it may be counted. Returning `false` denotes that the return of
  ///   ``count(while:)`` will be the amount of elements for which this predicate has yielded `true`
  ///   until this one.
  fileprivate func count(while predicate: (Element) -> Bool) -> Int {
    var count = 0
    for element in self {
      guard predicate(element) else { break }
      count += 1
    }
    return count
  }
}
