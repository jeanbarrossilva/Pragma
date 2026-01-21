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

struct DemoPlanTests {
  @Test
  func headlineIsNormalized() async throws {
    var plan = DemoPlanning.plans[0]
    try await plan.setTitle(to: " Title")
    try await plan.setSummary(to: "Summary. ")
    #expect(plan.title == "Title")
    #expect(plan.summary == "Summary.")
  }

  @Test
  func setsTitle() async throws {
    var plan = DemoPlanning.plans[0]
    let newTitle = "🥼"
    try await plan.setTitle(to: newTitle)
    #expect(plan.title == newTitle)
  }

  @Test
  func setsDescription() async throws {
    var plan = DemoPlanning.plans[0]
    let newSummary = "⚓️"
    try await plan.setSummary(to: newSummary)
    #expect(plan.summary == newSummary)
  }

  @Test
  func addsGoal() async throws {
    var plan = DemoPlanning.plans[0]
    let goal = try await plan.addGoal(titled: "🐻", summarizedBy: "🐰")
    #expect(plan.goals.contains(goal))
  }

  @Test
  func addedGoalHasNoToDosByDefault() async throws {
    var plan = DemoPlanning.plans[0]
    let addedGoal = try await plan.addGoal(titled: "🍦", summarizedBy: "🍨")
    #expect(plan.goals.first(where: { goal in goal == addedGoal })!.toDos.isEmpty)
    #expect(addedGoal.toDos.isEmpty)
  }

  @Test
  func removesGoal() async throws {
    var plan = DemoPlanning.plans.first(where: { plan in !plan.goals.isEmpty })!
    let goal = plan.goals[0]
    try await plan.removeGoal(identifiedAs: goal.id)
    #expect(!plan.goals.contains(goal))
  }
}
