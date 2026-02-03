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
  func headlineIsNormalized() async throws {
    var planner = InMemoryPlanner()
    let planID = try await planner.addPlan(describedBy: .samples[0])
    try await planner.withPlan(identifiedAs: planID) { plan in
      try await plan.withGoals { goals in
        try await goals.withElement(at: 0) { goal in
          let toDoID = try await goal.addToDo(
            describedBy: .init(
              title: " Title",
              abstract: "Abstract. ",
              status: .idle,
              deadline: .distantFuture
            )
          )
          try await goal.withToDo(identifiedAs: toDoID) { toDo in
            #expect(await toDo.title == "Title")
            #expect(await toDo.abstract == "Abstract.")
          }
        }
      }
    }
  }

  @Test
  func setsTitle() async throws {
    var planner = InMemoryPlanner()
    let planID = try await planner.addPlan(describedBy: .sample(.withGoals(.withToDos)))
    try await planner.withPlan(identifiedAs: planID) { plan in
      try await plan.withGoals { goals in
        try await goals.withElement(at: 0) { goal in
          try await goal.withToDos { toDos in
            try await toDos.withElement(at: 0) { toDo in
              let newTitle = "Title 🥸"
              try await toDo.setTitle(to: newTitle)
              #expect(await toDo.title == newTitle)
            }
          }
        }
      }
    }
  }

  @Test
  func setsDescription() async throws {
    var planner = InMemoryPlanner()
    let planID = try await planner.addPlan(describedBy: .sample(.withGoals(.withToDos)))
    try await planner.withPlan(identifiedAs: planID) { plan in
      try await plan.withGoals { goals in
        try await goals.withElement(at: 0) { goal in
          try await goal.withToDos { toDos in
            try await toDos.withElement(at: 0) { toDo in
              let newAbstract = "Abstract. 🏎️"
              try await toDo.setAbstract(to: newAbstract)
              #expect(await toDo.abstract == newAbstract)
            }
          }
        }
      }
    }
  }

  @Test
  func setsStatus() async throws {
    var planner = InMemoryPlanner()
    let planID = try await planner.addPlan(describedBy: .sample(.withGoals(.withToDos)))
    try await planner.withPlan(identifiedAs: planID) { plan in
      try await plan.withGoals { goals in
        try await goals.withElement(at: 0) { goal in
          try await goal.withToDos { toDos in
            try await toDos.withElement(at: 0) { toDo in
              let oldStatus = toDo.status
              let newStatus = Status.allCases.first(where: { status in oldStatus != status })!
              try await toDo.setStatus(to: newStatus)
              #expect(await toDo.status == newStatus)
            }
          }
        }
      }
    }
  }
}
