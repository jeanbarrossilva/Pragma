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

struct InMemoryPlannerTests {
  @Test(arguments: ReadOnlyPlan.samples)
  func addsPlan(basedOn descriptor: ReadOnlyPlan) async throws(PlannerError<NSError>) {
    let planner = InMemoryPlanner()
    let planID = try await planner.addPlan(basedOn: descriptor)
    _ = try await planner.plan(identifiedAs: planID)
  }

  @Test(arguments: ReadOnlyPlan.samples)
  func removesPlan(basedOn descriptor: ReadOnlyPlan) async throws(PlannerError<NSError>) {
    let planner = InMemoryPlanner()
    let planID = try await planner.addPlan(basedOn: descriptor)
    try await planner.removePlan(identifiedAs: planID)
    await #expect(throws: PlannerError<NSError>.nonexistent(type: InMemoryPlan.self, id: planID)) {
      try await planner.plan(identifiedAs: planID)
    }
  }

  @Test
  func clears() async throws {
    let planner = InMemoryPlanner()
    let planIDs = try await ReadOnlyPlan.samples.asyncMap { planDescriptor in
      try await planner.addPlan(basedOn: planDescriptor)
    }
    try await planner.clear()
    for planID in planIDs {
      await #expect(
        throws: PlannerError<NSError>.nonexistent(type: InMemoryPlan.self, id: planID)
      ) {
        try await planner.plan(identifiedAs: planID)
      }
    }
  }
}
