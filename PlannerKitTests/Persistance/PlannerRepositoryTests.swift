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

struct PlannerRepositoryTests {
  @Test
  func retrievingNonInsertedPlanReturnsNil() async throws {
    try await Planning.makeRepository(isInMemory: true).run { repository in
      let plan = try await repository.plan(identifiedAs: 0)
      #expect(plan == nil)
    }
  }

  @Test
  func addsPlan() async throws {
    try await Planning.makeRepository(isInMemory: true).run { repository in
      let addedPlan = try await repository.insertPlan(titled: "🦇", summarizedBy: "🐞")
      let retrievedPlan = try await repository.plan(identifiedAs: addedPlan.id)
      #expect(retrievedPlan?.title == addedPlan.title)
      #expect(retrievedPlan?.summary == addedPlan.summary)
      #expect(retrievedPlan?.goals == [] && addedPlan.goals == [])
    }
  }

  @Test
  func deletesPlan() async throws {
    try await Planning.makeRepository(isInMemory: true).run { repository in
      let addedPlan = try await repository.insertPlan(titled: "👽", summarizedBy: "🥄")
      try repository.deletePlan(identifiedAs: addedPlan.id)
      let retrievedPlan = try await repository.plan(identifiedAs: addedPlan.id)
      #expect(retrievedPlan == nil)
    }
  }
}
