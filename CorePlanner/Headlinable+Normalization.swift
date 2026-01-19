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

extension Headlined {
  /// Ensures that the `title` is not empty and trims it.
  ///
  /// This function *must* be called upon updates of the ``title``, and the property *must* be set
  /// to the resulting value.
  ///
  /// E.g.,
  ///
  /// ```swift
  /// struct Headline: Headlined {
  ///  public let id = UUID()
  ///  public private(set) var title: String
  ///  public private(set) var description: String
  ///
  ///  init(title: String, description: String) {
  ///    var title = title
  ///    Self.normalize(title: title)
  ///    self.title = title
  ///    var description = description
  ///    Self.normalize(description: description)
  ///    self.description = description
  ///  }
  ///
  ///   public mutating func setTitle(to newTitle: String) async {
  ///     var newTitle = newTitle
  ///     Self.normalize(title: newTitle)
  ///     title = newTitle
  ///   }
  ///
  ///   public mutating func setDescription(to newDescription: String) async {
  ///     var newDescription = newDescription
  ///     Self.normalize(description: newDescription)
  ///     description = newDescription
  ///   }
  /// }
  /// ```
  ///
  /// - Parameters:
  ///   - title: Title suggested for a ``Headlined``.
  public static func normalize(title: inout String) {
    precondition(!title.isBlank, "Title of a \(Self.description) cannot be blank.")
    title.trim(.whitespacesAndNewlines)
  }

  /// Trims a description.
  ///
  /// This function *must* be called upon updates of the ``description``, and the property *must* be
  /// set to the resulting value.
  ///
  /// E.g.,
  ///
  /// ```swift
  /// struct Headline: Headlined {
  ///  public let id = UUID()
  ///  public private(set) var title: String
  ///  public private(set) var description: String
  ///
  ///  init(title: String, description: String) {
  ///    var title = title
  ///    Self.normalize(title: title)
  ///    self.title = title
  ///    var description = description
  ///    Self.normalize(description: description)
  ///    self.description = description
  ///  }
  ///
  ///   public mutating func setTitle(to newTitle: String) async {
  ///     var newTitle = newTitle
  ///     Self.normalize(title: newTitle)
  ///     title = newTitle
  ///   }
  ///
  ///   public mutating func setDescription(to newDescription: String) async {
  ///     var newDescription = newDescription
  ///     Self.normalize(description: newDescription)
  ///     description = newDescription
  ///   }
  /// }
  /// ```
  ///
  /// - Parameters:
  ///   - description: Description suggested for a ``Headlined``.
  public static func normalize(description: inout String) {
    description.trim(.whitespacesAndNewlines)
  }
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
