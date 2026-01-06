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

struct DemoGoalTests {
  @Test
  func headlineIsNormalized() {
    let goal = DemoGoal(title: "Title ", description: " Description.")
    #expect(goal.title == "Title")
    #expect(goal.description == "Description.")
  }

  @Test
  func setsTitle() async {
    var goal = DemoGoal(title: "Title", description: "Description.")
    let newTitle = "Title 🔥"
    await goal.setTitle(to: newTitle)
    #expect(goal.title == newTitle)
  }

  @Test
  func setsDescription() async {
    var goal = DemoGoal(title: "Title", description: "Description.")
    let newDescription = "Description. 🐴"
    await goal.setDescription(to: newDescription)
    #expect(goal.description == newDescription)
  }

  @Test
  func addsToDo() async {
    var goal = DemoGoal(title: "Goal title", description: "Goal description.")
    let toDo = await goal.addToDo(
      titled: "To-do title",
      describedAs: "To-do description.",
      due: .distantFuture
    )
    #expect(goal.toDos.elementsEqual([toDo]))
  }

  @Test
  func addedToDoIsNotDoneByDefault() async {
    var goal = DemoGoal(title: "Goal title", description: "Goal description.")
    let toDo = await goal.addToDo(
      titled: "To-do title",
      describedAs: "To-do description.",
      due: .distantFuture
    )
    #expect(!goal.toDos[0].isDone)
    #expect(!toDo.isDone)
  }

  @Test
  func removesToDo() async {
    var goal = DemoGoal(title: "Goal title", description: "Goal description.")
    let maintainedToDo = await goal.addToDo(
      titled: "Maintained to-do title",
      describedAs: "Maintained to-do description.",
      due: .distantFuture
    )
    let removedToDo = await goal.addToDo(
      titled: "Removed to-do title",
      describedAs: "Removed to-do description.",
      due: .distantFuture
    )
    await goal.removeToDo(identifiedAs: removedToDo.id)
    #expect(goal.toDos.elementsEqual([maintainedToDo]))
  }
}
