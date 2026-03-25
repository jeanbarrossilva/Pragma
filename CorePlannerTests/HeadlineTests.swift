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

@testable import CorePlanner
import Testing

struct HeadlineTests {
  @Test(arguments: ["Title", " Title", "Title "])
  func normalizes(title: String) {
    let headline = Headline.from(title: title, summary: "")
    #expect(headline.title == "Title")
  }

  @Test(arguments: ["Summary.", " Summary.", "Summary. "])
  func normalizes(summary: String) {
    let headline = Headline.from(title: "Title", summary: summary)
    #expect(headline.summary == "Summary.")
  }
}
