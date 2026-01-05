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

import Foundation
@testable import PlannerKit
import Testing

struct InMemoryGoalTests {
  @Test
  func headlineIsNormalized() {
    let goal = InMemoryGoal(title: "Title ", description: " Description.")
    #expect(goal.title == "Title")
    #expect(goal.description == "Description.")
  }

  @Test
  func setsTitle() async {
    var goal = InMemoryGoal(title: "Title", description: "Description.")
    let newTitle = "Title 🔥"
    await goal.setTitle(to: newTitle)
    #expect(goal.title == newTitle)
  }

  @Test
  func setsDescription() async {
    var goal = InMemoryGoal(title: "Title", description: "Description.")
    let newDescription = "Description. 🐴"
    await goal.setDescription(to: newDescription)
    #expect(goal.description == newDescription)
  }

  @Test
  func addsToDo() async {
    var goal = InMemoryGoal(title: "Goal title", description: "Goal description.")
    let toDoTitle = "To-do title"
    let toDoDescription = "To-do description."
    let toDoDeadline = Date.distantFuture
    let toDoID = await goal.addToDo(
      titled: toDoTitle,
      describedAs: toDoDescription,
      due: toDoDeadline
    )
    #expect(
      goal.toDos.elementsEqual([
        .init(id: toDoID, title: toDoTitle, description: toDoDescription, deadline: toDoDeadline)
      ])
    )
  }

  @Test
  func addedToDoIsNotDoneByDefault() async {
    var goal = InMemoryGoal(title: "Goal title", description: "Goal description.")
    let toDoTitle = "To-do title"
    let toDoDescription = "To-do description."
    let toDoDeadline = Date.distantFuture
    let _ = await goal.addToDo(titled: toDoTitle, describedAs: toDoDescription, due: toDoDeadline)
    #expect(!goal.toDos[0].isDone)
  }

  @Test
  func removesToDo() async {
    var goal = InMemoryGoal(title: "Goal title", description: "Goal description.")
    let maintainedToDoTitle = "Maintained to-do title"
    let maintainedToDoDescription = "Maintained to-do description."
    let maintainedToDoDeadline = Date.distantFuture
    let maintainedToDoID = await goal.addToDo(
      titled: maintainedToDoTitle,
      describedAs: maintainedToDoDescription,
      due: maintainedToDoDeadline
    )
    let removedToDoTitle = "Removed to-do title"
    let removedToDoDescription = "Removed to-do description."
    let removedToDoDeadline = Date.distantFuture
    let removedToDoID = await goal.addToDo(
      titled: removedToDoTitle,
      describedAs: removedToDoDescription,
      due: removedToDoDeadline
    )
    await goal.removeToDo(identifiedAs: removedToDoID)
    #expect(
      goal.toDos.elementsEqual([
        .init(
          id: maintainedToDoID,
          title: maintainedToDoTitle,
          description: maintainedToDoDescription,
          deadline: maintainedToDoDeadline
        )
      ])
    )
  }
}
