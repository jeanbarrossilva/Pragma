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
    NoOpHeadline.normalize(title: &title)
    #expect(title == "Title")
  }

  @Test(arguments: [" Summary.", "Summary. "])
  func trims(summary: String) {
    var summary = summary
    NoOpHeadline.normalize(summary: &summary)
    #expect(summary == "Summary.")
  }
}

// This type exists merely for us to have access to the static normalize(title:) and
// normalize(summary:) functions. Its implementation is incorrect — it is no-op, as the name
// suggests — and should not be taken as an example for future implementations of Headlined.
private struct NoOpHeadline: Headlined {
  typealias ImplementationError = Error

  let id: UUID
  let title: String
  let summary: String

  static let description = "no-op headline"

  func setTitle(to newTitle: String) async throws(PlannerError<Error>) {}
  func setSummary(to newSummary: String) async throws(PlannerError<Error>) {}
}
