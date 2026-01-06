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

@testable import Planner
import Testing

@Suite("Headlined+Normalization tests")
struct HeadlinedNormalizationTests {
  @Test(arguments: [" Title", "Title "])
  func trims(title: String) {
    var title = title
    var description = ""
    normalize(&title, &description, typeDescription: "headline")
    #expect(title == "Title")
  }

  @Test(arguments: [" Description.", "Description. "])
  func trims(description: String) {
    var title = "Title"
    var description = description
    normalize(&title, &description, typeDescription: "headline")
    #expect(description == "Description.")
  }
}
