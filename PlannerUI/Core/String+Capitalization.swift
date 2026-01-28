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

extension StringProtocol {
  /// A copy of the string with each word changed to its corresponding decapitalized spelling.
  ///
  /// This is the inverse of ``capitalized``.
  var decapitalized: String {
    guard let first else { return self as? String ?? .init(self) }
    var decapitalized = first.lowercased()
    if count > 1 { decapitalized += self[index(after: startIndex)...] }
    return decapitalized
  }
}
