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

@testable import CorePlanner
import Testing

@Suite("Headlined+Normalization tests")
struct HeadlinedNormalizationTests {
  @Test(arguments: [" Title", "Title "])
  func trims(title: String) {
    var title = title
    var description = ""
    NoOpHeadline.normalize(&title, &description)
    #expect(title == "Title")
  }

  @Test(arguments: [" Description.", "Description. "])
  func trims(description: String) {
    var title = "Title"
    var description = description
    NoOpHeadline.normalize(&title, &description)
    #expect(description == "Description.")
  }
}

// This type exists merely for us to have access to the static normalize(_:_:) method. Its
// implementation is incorrect — it is no-op, as the name suggests — and should not be taken as an
// example for future implementations of Headlined.
private struct NoOpHeadline: Headlined {
  let id: UUID
  let title: String
  let description: String

  static let description = "no-op headline"

  func setTitle(to newTitle: String) async {}
  func setDescription(to newDescription: String) async {}
}

extension NoOpHeadline: Comparable {
  public static func < (lhs: Self, rhs: Self) -> Bool { lhs.isLesser(than: rhs) }
}
