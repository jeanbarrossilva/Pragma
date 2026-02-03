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

struct InMemoryPlanTests {
  @Test
  func headlineIsNormalized() async throws {
    var planner = InMemoryPlanner()
    let planID = try await planner.addPlan(describedBy: .samples[0])
    let plan = try await planner.plan(identifiedAs: planID)
    try await plan.setTitle(to: " Title")
    try await plan.setAbstract(to: "abstract. ")
    #expect(await plan.title == "Title")
    #expect(await plan.abstract == "abstract.")
  }

  @Test
  func setsTitle() async throws {
    var planner = InMemoryPlanner()
    let planID = try await planner.addPlan(describedBy: .samples[0])
    let plan = try await planner.plan(identifiedAs: planID)
    let newTitle = "🥼"
    try await plan.setTitle(to: newTitle)
    #expect(await plan.title == newTitle)
  }

  @Test
  func setsDescription() async throws {
    var planner = InMemoryPlanner()
    let planID = try await planner.addPlan(describedBy: .samples[0])
    let plan = try await planner.plan(identifiedAs: planID)
    let newAbstract = "⚓️"
    try await plan.setAbstract(to: newAbstract)
    #expect(await plan.abstract == newAbstract)
  }

  @Test
  func addsGoal() async throws {
    var planner = InMemoryPlanner()
    let planID = try await planner.addPlan(describedBy: .sample(.withoutGoals))
    let plan = try await planner.plan(identifiedAs: planID)
    let goalID = try await plan.addGoal(describedBy: .init(title: "🐻", abstract: "🐰"))
    _ = try await plan.goal(identifiedAs: goalID)
  }

  @Test
  func addedGoalHasNoToDosByDefault() async throws {
    var planner = InMemoryPlanner()
    let planID = try await planner.addPlan(describedBy: .sample(.withoutGoals))
    let plan = try await planner.plan(identifiedAs: planID)
    let goalID = try await plan.addGoal(describedBy: .init(title: "🍦", abstract: "🍨"))
    let goal = try await plan.goal(identifiedAs: goalID)
    #expect(await goal.toDos.isEmpty)
  }

  @Test
  func removesGoal() async throws {
    var planner = InMemoryPlanner()
    let planID = try await planner.addPlan(describedBy: .sample(.withGoals))
    let plan = try await planner.plan(identifiedAs: planID)
    let goalID = plan.goals[0].id
    try await plan.removeGoal(identifiedAs: goalID)
    await #expect(throws: PlannerError<NSError>.nonexistent(type: InMemoryGoal.self, id: goalID)) {
      try await plan.goal(identifiedAs: goalID)
    }
  }
}
