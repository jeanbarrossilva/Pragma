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

/// ``Headlined`` which allows for asynchronous modifications of its
/// ``Headlined/title`` and ``Headlined/summary``.
@available(*, deprecated, message: "Headline should be implemented manually.")
public protocol Headlineable: Headlined {
  /// Changes the ``Headlined/title``.
  ///
  /// - Parameter newTitle: Title by which the current one will be replaced.
  mutating func setTitle(to newTitle: String) async throws

  /// Changes the ``Headlined/summary``.
  ///
  /// - Parameter newSummary: Summary by which the current one will be replaced.
  mutating func setSummary(to newSummary: String) async throws
}

/// Structs or classes conforming to this protocol are presentable by a general,
/// short summary; and a more descriptive, longer one. These may be mutable in
/// case such structs or classes also conform to ``Headlineable``.
@available(
  *,
  deprecated,
  message: "Title and abstract should be implemented manually."
)
public protocol Headlined: Comparable, Hashable, Identifiable, SendableMetatype
{
  /// Main, general, non-blank summary.
  var title: String { get }

  /// Secondary, detailed explanation related to the contents of the ``title``.
  /// May be blank.
  var summary: String { get }
}

extension Headlined where Self: Comparable {
  /// Compares the ``title`` and the ``summary`` of both objects, allowing for
  /// them to be sorted alphabetically in an implementation of the ``<(_:_:)``
  /// function. Should be called and have its return considered by every
  /// implementation of this type when a result of the latter function is given.
  ///
  /// - Parameter other: Right-hand-side of the comparison.
  public func isLesser(than other: Self) -> Bool {
    title[title.startIndex] < other.title[other.title.startIndex]
      && summary[summary.startIndex] < other.summary[other.summary.startIndex]
  }

  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.isLesser(than: rhs)
  }
}

extension Headlined where Self: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
}

// MARK: - Normalization

/// Ensures that a title is not empty and trims it.
///
/// This function *must* be called upon updates of the title, and the backing
/// property *must* be set to the resulting value.
///
/// - Parameters:
///   - title: Title suggested for a headline.
@available(
  *,
  deprecated,
  message: "Produce a headline from 'Headline.from(title:summary:)' instead."
)
public func normalize(title: inout String) {
  var summary = ""
  title = Headline.from(title: title, summary: summary).title
}

/// Trims a ``summary``.
///
/// This function *must* be called upon updates of the summary, and the backing
/// property *must* be set to the resulting value.
///
/// - Parameters:
///   - summary: Summary suggested for a headline.
@available(
  *,
  deprecated,
  message: "Produce a headline from 'Headline.from(title:summary:)' instead."
)
public func normalize(summary: inout String) {
  var title = "Title"
  summary = Headline.from(title: title, summary: summary).summary
}
