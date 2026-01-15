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
  func headlineIsNormalized() async {
    var plan = DemoPlanning.plans[0]
    await plan.setTitle(to: " Title")
    await plan.setDescription(to: "Description. ")
    #expect(plan.title == "Title")
    #expect(plan.description == "Description.")
  }

  @Test
  func setsTitle() async {
    var plan = DemoPlanning.plans[0]
    let newTitle = "🥼"
    await plan.setTitle(to: newTitle)
    #expect(plan.title == newTitle)
  }

  @Test
  func setsDescription() async {
    var plan = DemoPlanning.plans[0]
    let newDescription = "⚓️"
    await plan.setDescription(to: newDescription)
    #expect(plan.description == newDescription)
  }

  @Test
  func addsGoal() async {
    var plan = DemoPlanning.plans[0]
    let goal = await plan.addGoal(titled: "🐻", describedAs: "🐰")
    #expect(plan.goals.contains(goal))
  }

  @Test
  func addedGoalHasNoToDosByDefault() async {
    var plan = DemoPlanning.plans[0]
    let addedGoal = await plan.addGoal(titled: "🍦", describedAs: "🍨")
    #expect(plan.goals.first(where: { goal in goal == addedGoal })!.toDos.isEmpty)
    #expect(addedGoal.toDos.isEmpty)
  }

  @Test
  func removesGoal() async {
    var plan = DemoPlanning.plans.first(where: { plan in !plan.goals.isEmpty })!
    let goal = plan.goals[0]
    await plan.removeGoal(identifiedAs: goal.id)
    #expect(!plan.goals.contains(goal))
  }
}
