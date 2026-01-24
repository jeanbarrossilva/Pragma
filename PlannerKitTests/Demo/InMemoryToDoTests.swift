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

struct InMemoryToDoTests {
  @Test
  func headlineIsNormalized() async throws(PlannerError<NSError>) {
    let planner = InMemoryPlanner()
    let planID = try await planner.addPlan(describedBy: .samples[0])
    let plan = try await planner.plan(identifiedAs: planID)
    var goal = await plan.goals[0]
    let toDoID = try await goal.addToDo(
      titled: " Title",
      summarizedBy: "Summary. ",
      due: .distantFuture
    )
    let toDo = try await goal.toDo(identifiedAs: toDoID)
    #expect(await toDo.title == "Title")
    #expect(await toDo.summary == "Summary.")
  }

  @Test
  func setsTitle() async throws(PlannerError<NSError>) {
    let planner = InMemoryPlanner()
    let planID = try await planner.addPlan(describedBy: .sample(.withGoals(.withToDos)))
    let toDo = try await planner.plan(identifiedAs: planID).goals[0].toDos[0]
    let newTitle = "Title 🥸"
    try await toDo.setTitle(to: newTitle)
    #expect(await toDo.title == newTitle)
  }

  @Test
  func setsDescription() async throws(PlannerError<NSError>) {
    let planner = InMemoryPlanner()
    let planID = try await planner.addPlan(describedBy: .sample(.withGoals(.withToDos)))
    let toDo = try await planner.plan(identifiedAs: planID).goals[0].toDos[0]
    let newSummary = "Summary. 🏎️"
    try await toDo.setSummary(to: newSummary)
    #expect(await toDo.summary == newSummary)
  }

  @Test
  func setsStatus() async throws(PlannerError<NSError>) {
    let planner = InMemoryPlanner()
    let planID = try await planner.addPlan(describedBy: .sample(.withGoals(.withToDos)))
    let toDo = try await planner.plan(identifiedAs: planID).goals[0].toDos[0]
    let oldStatus = await toDo.status
    let newStatus = Status.allCases.first(where: { status in oldStatus != status })!
    try await toDo.setStatus(to: newStatus)
    #expect(await toDo.status == newStatus)
  }
}
