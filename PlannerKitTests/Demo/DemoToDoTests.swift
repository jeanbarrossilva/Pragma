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

@testable import PlannerKit
import Testing

struct DemoToDoTests {
  @Test
  func headlineIsNormalized() async throws {
    var toDo = DemoPlanning.toDos[0]
    try await toDo.setTitle(to: " Title")
    try await toDo.setDescription(to: "Description. ")
    #expect(toDo.title == "Title")
    #expect(toDo.description == "Description.")
  }

  @Test
  func setsTitle() async throws {
    var toDo = DemoPlanning.toDos[0]
    let newTitle = "Title 🥸"
    try await toDo.setTitle(to: newTitle)
    #expect(toDo.title == newTitle)
  }

  @Test
  func setsDescription() async throws {
    var toDo = DemoPlanning.toDos[0]
    let newDescription = "Description. 🏎️"
    try await toDo.setDescription(to: newDescription)
    #expect(toDo.description == newDescription)
  }

  @Test
  func setsStatus() async throws {
    var toDo = DemoPlanning.toDos[0]
    let newStatus = Status.allCases.first(where: { status in toDo.status != status })!
    try await toDo.setStatus(to: newStatus)
    #expect(toDo.status == newStatus)
  }
}
