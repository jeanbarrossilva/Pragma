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

struct GoalToDoTests {
  @Test
  func headlineIsNormalized() {
    let toDo = DemoToDo(title: "Title ", description: " Description.", deadline: .distantFuture)
    #expect(toDo.title == "Title")
    #expect(toDo.description == "Description.")
  }

  @Test
  func setsTitle() async {
    var toDo = DemoToDo(title: "Title", description: "Description.", deadline: .distantFuture)
    let newTitle = "Title 🥸"
    await toDo.setTitle(to: newTitle)
    #expect(toDo.title == newTitle)
  }

  @Test
  func setsDescription() async {
    var toDo = DemoToDo(title: "Title", description: "Description.", deadline: .distantFuture)
    let newDescription = "Description. 🏎️"
    await toDo.setDescription(to: newDescription)
    #expect(toDo.description == newDescription)
  }

  @Test
  func isNotDoneByDefault() {
    var toDo = DemoToDo(title: "Title", description: "Description.", deadline: .distantFuture)
    #expect(!toDo.isDone)
  }

  @Test
  func toggles() async {
    var toDo = DemoToDo(title: "Title", description: "Description.", deadline: .distantFuture)
    await toDo.toggle()
    #expect(toDo.isDone)
  }
}
