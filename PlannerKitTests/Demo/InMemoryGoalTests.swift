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

fileprivate struct InMemoryGoalTests {
  @Test(arguments: AnyGoalDescriptor.samples)
  func normalizesHeadline(of descriptor: AnyGoalDescriptor) async throws(PlannerError<NSError>) {
    let planner = InMemoryPlanner()
    let planID = try await planner.addPlan(describedBy: .sample(.withoutGoals))
    let plan = try await planner.plan(identifiedAs: planID)
    let goalID = try await plan.addGoal(describedBy: .init(title: " Title", summary: "Summary. "))
    let goal = try await plan.goal(identifiedAs: goalID)
    #expect(await goal.title == "Title")
    #expect(await goal.summary == "Summary.")
  }

  @Test
  func setsTitle() async throws(PlannerError<NSError>) {
    let planner = InMemoryPlanner()
    let planID = try await planner.addPlan(describedBy: .sample(.withGoals(.withToDos)))
    let plan = try await planner.plan(identifiedAs: planID)
    let goal = await plan.goals[0]
    let newTitle = "🔥"
    try await goal.setTitle(to: newTitle)
    #expect(await goal.title == newTitle)
  }

  @Test
  func setsDescription() async throws(PlannerError<NSError>) {
    let planner = InMemoryPlanner()
    let planID = try await planner.addPlan(describedBy: .sample(.withGoals(.withToDos)))
    let plan = try await planner.plan(identifiedAs: planID)
    let goal = await plan.goals[0]
    let newSummary = "🐴"
    try await goal.setSummary(to: newSummary)
    #expect(await goal.summary == newSummary)
  }

  @Test
  func addsToDo() async throws(PlannerError<NSError>) {
    let planner = InMemoryPlanner()
    let planID = try await planner.addPlan(describedBy: .sample(.withGoals))
    let plan = try await planner.plan(identifiedAs: planID)
    let goal = await plan.goals[0]
    let toDoID = try await goal.addToDo(
      describedBy: .init(title: "🔭", summary: "🔬", status: .idle, deadline: .distantFuture)
    )
    _ = try await goal.toDo(identifiedAs: toDoID)
  }

  @Test
  func removesToDo() async throws(PlannerError<NSError>) {
    let planner = InMemoryPlanner()
    let planID = try await planner.addPlan(describedBy: .sample(.withGoals(.withToDos)))
    let plan = try await planner.plan(identifiedAs: planID)
    let goal = await plan.goals[0]
    let toDoID = await goal.toDos[0].id
    try await goal.removeToDo(identifiedAs: toDoID)
    try await #expect(
      throws: PlannerError<NSError>.nonexistent(type: InMemoryToDo.self, id: await toDoID)
    ) {
      try await goal.toDo(identifiedAs: toDoID)
    }
  }
}
