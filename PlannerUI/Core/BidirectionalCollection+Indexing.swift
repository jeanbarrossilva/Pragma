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

extension BidirectionalCollection where Element: Equatable {
  /// Obtains the element preceding the given one in this collection, or `nil` if the given one is
  /// not in this collection. If the given one is present twice, once at the first index and again
  /// at index *n*, the element at index *n* - 1 will be obtained.
  ///
  /// - Complexity: O(*n*), where *n* is the amount of elements in this collection.
  /// - Parameter element: Element whose predecessor should be returned.
  func before(_ element: Element) -> Element? {
    guard var relativeIndex = firstIndex(of: element) else { return nil }
    if relativeIndex == startIndex,
      count > 1,
      let _relativeIndex = self[index(after: relativeIndex)...].firstIndex(of: element)
    {
      relativeIndex = _relativeIndex
    }
    return self[index(before: relativeIndex)]
  }
}
