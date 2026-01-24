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
    let planner = InMemoryPlanner()
    let planID = try await planner.addPlan(basedOn: .samples[0])
    let plan = try await planner.plan(identifiedAs: planID)
    try await plan.setTitle(to: " Title")
    try await plan.setSummary(to: "Summary. ")
    #expect(await plan.title == "Title")
    #expect(await plan.summary == "Summary.")
  }

  @Test
  func setsTitle() async throws {
    let planner = InMemoryPlanner()
    let planID = try await planner.addPlan(basedOn: .samples[0])
    let plan = try await planner.plan(identifiedAs: planID)
    let newTitle = "🥼"
    try await plan.setTitle(to: newTitle)
    #expect(await plan.title == newTitle)
  }

  @Test
  func setsDescription() async throws {
    let planner = InMemoryPlanner()
    let planID = try await planner.addPlan(basedOn: .samples[0])
    let plan = try await planner.plan(identifiedAs: planID)
    let newSummary = "⚓️"
    try await plan.setSummary(to: newSummary)
    #expect(await plan.summary == newSummary)
  }

  @Test
  func addsGoal() async throws {
    let planner = InMemoryPlanner()
    let planID = try await planner.addPlan(basedOn: .sample(.withoutGoals))
    let plan = try await planner.plan(identifiedAs: planID)
    let goalID = try await plan.addGoal(titled: "🐻", summarizedBy: "🐰")
    _ = try await plan.goal(identifiedAs: goalID)
  }

  @Test
  func addedGoalHasNoToDosByDefault() async throws {
    let planner = InMemoryPlanner()
    let planID = try await planner.addPlan(basedOn: .sample(.withoutGoals))
    let plan = try await planner.plan(identifiedAs: planID)
    let goalID = try await plan.addGoal(titled: "🍦", summarizedBy: "🍨")
    let goal = try await plan.goal(identifiedAs: goalID)
    #expect(await goal.toDos.isEmpty)
  }

  @Test
  func removesGoal() async throws {
    let planner = InMemoryPlanner()
    let planID = try await planner.addPlan(basedOn: .sample(.withGoals))
    let plan = try await planner.plan(identifiedAs: planID)
    let goalID = await plan.goals[0].id
    try await plan.removeGoal(identifiedAs: goalID)
    await #expect(throws: PlannerError<NSError>.nonexistent(type: InMemoryGoal.self, id: goalID)) {
      try await plan.goal(identifiedAs: goalID)
    }
  }
}
