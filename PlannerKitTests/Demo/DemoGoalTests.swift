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

struct DemoGoalTests {
  @Test
  func headlineIsNormalized() async throws {
    var goal = DemoPlanning.goals[0]
    try await goal.setTitle(to: " Title")
    try await goal.setDescription(to: "Description. ")
    #expect(goal.title == "Title")
    #expect(goal.description == "Description.")
  }

  @Test
  func setsTitle() async throws {
    var goal = DemoPlanning.goals[0]
    let newTitle = "🔥"
    try await goal.setTitle(to: newTitle)
    #expect(goal.title == newTitle)
  }

  @Test
  func setsDescription() async throws {
    var goal = DemoPlanning.goals[0]
    let newDescription = "🐴"
    try await goal.setDescription(to: newDescription)
    #expect(goal.description == newDescription)
  }

  @Test
  func addsToDo() async throws {
    var goal = DemoPlanning.goals[0]
    let toDo = try await goal.addToDo(titled: "🔭", describedAs: "🔬", due: .distantFuture)
    #expect(goal.toDos.contains(toDo))
  }

  @Test
  func addedToDoIsIdleByDefault() async throws {
    var goal = DemoPlanning.goals[0]
    let toDo = try await goal.addToDo(
      titled: "To-do title",
      describedAs: "To-do description.",
      due: .distantFuture
    )
    #expect(goal.toDos[0].status == .idle)
    #expect(toDo.status == .idle)
  }

  @Test
  func removesToDo() async throws {
    var goal = DemoPlanning.goals.first(where: { goal in !goal.toDos.isEmpty })!
    let toDo = goal.toDos[0]
    try await goal.removeToDo(identifiedAs: toDo.id)
    #expect(!goal.toDos.contains(toDo))
  }
}
