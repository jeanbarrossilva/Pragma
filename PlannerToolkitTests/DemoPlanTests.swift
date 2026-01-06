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

@testable import PlannerToolkit
import Testing

struct DemoPlanTests {
  @Test
  func headlineIsNormalized() {
    let plan = DemoPlan(title: "Title ", description: " Description.")
    #expect(plan.title == "Title")
    #expect(plan.description == "Description.")
  }

  @Test
  func setsTitle() async {
    var plan = DemoPlan(title: "Title", description: "Description.")
    let newTitle = "Title 🥼"
    await plan.setTitle(to: newTitle)
    #expect(plan.title == newTitle)
  }

  @Test
  func setsDescription() async {
    var plan = DemoPlan(title: "Title", description: "Description.")
    let newDescription = "Description. ⚓️"
    await plan.setDescription(to: newDescription)
    #expect(plan.description == newDescription)
  }

  @Test
  func addsGoal() async {
    var plan = DemoPlan(title: "Goal title", description: "Goal description.")
    let goal = await plan.addGoal(titled: "To-do title", describedAs: "To-do description.")
    #expect(plan.goals.elementsEqual([goal]))
  }

  @Test
  func addedGoalHasNoToDosByDefault() async {
    var plan = DemoPlan(title: "Title", description: "Description.")
    let goal = await plan.addGoal(titled: "To-do title", describedAs: "To-do description.")
    #expect(plan.goals[0].toDos.isEmpty)
    #expect(goal.toDos.isEmpty)
  }

  @Test
  func removesGoal() async {
    var plan = DemoPlan(title: "Goal title", description: "Goal description.")
    let maintainedGoal = await plan.addGoal(
      titled: "Maintained goal title",
      describedAs: "Maintained goal description."
    )
    let removedGoal = await plan.addGoal(
      titled: "Removed goal title",
      describedAs: "Removed goal description."
    )
    await plan.removeGoal(identifiedAs: removedGoal.id)
    #expect(plan.goals.elementsEqual([maintainedGoal]))
  }
}
