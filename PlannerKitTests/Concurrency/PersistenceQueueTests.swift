// ===-----------------------------------------------------------------------===
// Copyright © 2026 Jean Silva
//
// This file is part of the Pragma open-source project.
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program. If not, see https://www.gnu.org/licenses.
// ===-----------------------------------------------------------------------===

@testable import PlannerKit
import SwiftData
import Testing

struct PersistenceQueueTests {
  @Suite("Fetching")
  struct FetchingTests {
    @Test
    func fetchingOneNonexistentModelReturnsNil() async throws {
      try await withPersistenceQueue { contextQueue in
        let fetchedModel = try contextQueue.fetch(.one(PlanModel.self))
        #expect(fetchedModel == nil)
      }
    }

    @Test
    func fetchesOneExistingModel() async throws {
      try await withPersistenceQueue { contextQueue in
        let insertedModel = makePlanModel()
        contextQueue.enqueue(.insertion(of: insertedModel))
        try await contextQueue.flush()
        let fetchedModel = try contextQueue.fetch(.one(PlanModel.self))
        #expect(fetchedModel?.uuid == insertedModel.uuid)
      }
    }

    @Test
    func fetchesAllModels() async throws {
      try await withPersistenceQueue { contextQueue in
        let insertedModels = makePlanModels()
        for insertedModel in insertedModels {
          contextQueue.enqueue(.insertion(of: insertedModel))
        }
        try await contextQueue.flush()
        let fetchedModels = Set(try contextQueue.fetch(.all(PlanModel.self)))
        #expect(fetchedModels.count == insertedModels.count)
      }
    }
  }

  @Suite("Insertion")
  struct InsertionTests {
    @Test
    func doesNotInsertBeforeFlushing() async throws {
      try await withPersistenceQueue { contextQueue in
        let toBeInsertedModel = makePlanModel()
        contextQueue.enqueue(.insertion(of: toBeInsertedModel))
        let fetchedModel = try contextQueue.fetch(.one(PlanModel.self))
        #expect(fetchedModel == nil)
      }
    }

    @Test
    func inserts() async throws {
      try await withPersistenceQueue { contextQueue in
        let insertedModel = makePlanModel()
        contextQueue.enqueue(.insertion(of: insertedModel))
        try await contextQueue.flush()
        let fetchedModels = try contextQueue.fetch(.all(PlanModel.self))
        #expect(
          fetchedModels.elementsEqual(
            [insertedModel],
            by: { oneModel, anotherModel in oneModel.uuid == anotherModel.uuid }
          )
        )
      }
    }
  }

  @Test
  func deletesOne() async throws {
    try await withPersistenceQueue { contextQueue in
      let insertedModel = makePlanModel()
      contextQueue.enqueue(.insertion(of: insertedModel))
      try await contextQueue.flush()
      let preDeletionFetchedModel = try! contextQueue.fetch(
        .one(PlanModel.self)
      )!
      contextQueue.enqueue(
        .deletion(of: PlanModel.self, identifiedAs: preDeletionFetchedModel.id)
      )
      try await contextQueue.flush()
      let postDeletionFetchedModels = try! contextQueue.fetch(
        .all(PlanModel.self)
      )
      #expect(postDeletionFetchedModels.isEmpty)
    }
  }

  @Test
  func deletesMany() async throws {
    try await withPersistenceQueue { contextQueue in
      let planModels = makePlanModels()
      let goalModels = makeGoalModels(of: planModels)
      for planModel in planModels {
        contextQueue.enqueue(.insertion(of: planModel))
      }
      for goalModel in goalModels {
        contextQueue.enqueue(.insertion(of: goalModel))
      }
      contextQueue.enqueue(.deletion(ofType: PlanModel.self))
      try await contextQueue.flush()
      let plans = try contextQueue.fetch(.all(PlanModel.self))
      let goals = try contextQueue.fetch(.all(GoalModel.self))
      #expect(plans.isEmpty)
      #expect(!goals.isEmpty)
    }
  }

  @Suite("Deletion (all)")
  struct DeletionOfAllTests {
    @Test
    func deletesAll() async throws {
      try await withPersistenceQueue { contextQueue in
        let planModels = makePlanModels()
        let goalModels = makeGoalModels(of: planModels)
        for planModel in planModels {
          contextQueue.enqueue(.insertion(of: planModel))
        }
        for goalModel in goalModels {
          contextQueue.enqueue(.insertion(of: goalModel))
        }
        contextQueue.enqueue(.deletionOfAll)
        try await contextQueue.flush()
        let fetchedPlanModels = try contextQueue.fetch(.all(PlanModel.self))
        let fetchedGoalModels = try contextQueue.fetch(.all(GoalModel.self))
        #expect(fetchedPlanModels.isEmpty)
        #expect(fetchedGoalModels.isEmpty)
      }
    }
  }
}

private func makePlanModels() -> some Collection<PlanModel> {
  [PlanModel](count: 128) { _ in makePlanModel() }
}

private func makePlanModel() -> PlanModel {
  .init(uuid: .init(), title: "", summary: "")
}

private func makeGoalModels(
  of planModels: some Sequence<PlanModel>
) -> some Sequence<GoalModel> {
  planModels.map { plan in
    GoalModel(uuid: .init(), planUUID: plan.uuid, title: "", summary: "")
  }
}
