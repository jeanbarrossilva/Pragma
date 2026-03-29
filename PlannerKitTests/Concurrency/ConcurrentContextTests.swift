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

struct ModelContextQueueTests {
  @Suite("Fetching")
  struct FetchingTests {
    @Test
    func fetchingOneNonexistentModelReturnsNil() async throws {
      try await ModelContextQueue(
        container: PersistentPlanRepository.makeContainer(isInMemory: true)
      )
      .run { contextQueue in
        let fetchedModel = try contextQueue.fetch(
          .one,
          where: Predicate<PlanModel>.true
        )
        #expect(fetchedModel == nil)
      }
    }

    @Test
    func fetchesOneExistingModel() async throws {
      try await ModelContextQueue(
        container: PersistentPlanRepository.makeContainer(isInMemory: true)
      )
      .run { contextQueue in
        let insertedModel = PlanModel(uuid: .init(), title: "", summary: "")
        contextQueue.enqueue(.insertion(of: insertedModel))
        try await contextQueue.flush()
        let fetchedModel = try contextQueue.fetch(
          .one,
          where: Predicate<PlanModel>.true
        )
        #expect(fetchedModel == insertedModel)
      }
    }

    @Test
    func fetchesAllModels() async throws {
      try await ModelContextQueue(
        container: PersistentPlanRepository.makeContainer(isInMemory: true)
      )
      .run { contextQueue in
        let insertedModels = [PlanModel](count: 128) { _ in
          .init(uuid: .init(), title: "", summary: "")
        }
        for insertedModel in insertedModels {
          contextQueue.enqueue(.insertion(of: insertedModel))
        }
        try await contextQueue.flush()
        let fetchedModels = try contextQueue.fetch(
          .all,
          where: Predicate<PlanModel>.true
        )
        #expect(fetchedModels == insertedModels)
      }
    }
  }

  @Test
  func inserts() async throws {
    try await ModelContextQueue(
      container: PersistentPlanRepository.makeContainer(isInMemory: true)
    )
    .run { contextQueue in
      let model = PlanModel(uuid: .init(), title: "", summary: "")
      contextQueue.enqueue(.insertion(of: model))
      try await contextQueue.flush()
      let models = try contextQueue.fetch(
        .all,
        where: Predicate<PlanModel>.true
      )
      #expect(models.elementsEqual([model]))
    }
  }

  @Test
  func deletesOne() async throws {
    try await ModelContextQueue(
      container: PersistentPlanRepository.makeContainer(isInMemory: true)
    )
    .run { contextQueue in
      let model = PlanModel(uuid: .init(), title: "", summary: "")
      contextQueue.enqueue(.insertion(of: model))
      contextQueue.enqueue(.deletion(of: model))
      try await contextQueue.flush()
      let models = try contextQueue.fetch(
        .all,
        where: Predicate<PlanModel>.true
      )
      #expect(models.isEmpty)
    }
  }

  @Test
  func deletesMany() async throws {
    let contextQueue = try ModelContextQueue(
      container: PersistentPlanRepository.makeContainer(isInMemory: true)
    )
    let planSnapshots = [Snapshot<PlanModel>](count: 2) { _ in
      .init(of: .init(uuid: .init(), title: "", summary: ""))
    }
    let goalSnapshots = planSnapshots.map { planSnapshot in
      Snapshot(
        of: GoalModel(
          uuid: .init(),
          planUUID: planSnapshot.copy().uuid,
          title: "",
          summary: ""
        )
      )
    }
    let toDoSnapshots = goalSnapshots.map { goalSnapshot in
      Snapshot(
        of: ToDoModel(
          uuid: .init(),
          goalUUID: goalSnapshot.copy().uuid,
          title: "",
          summary: "",
          status: .idle,
          deadline: .distantFuture
        )
      )
    }
    for planSnapshot in planSnapshots {
      await contextQueue.enqueue(.insertion(of: planSnapshot.copy()))
    }
    for goalSnapshot in goalSnapshots {
      await contextQueue.enqueue(.insertion(of: goalSnapshot.copy()))
    }
    for toDoSnapshot in toDoSnapshots {
      await contextQueue.enqueue(.insertion(of: toDoSnapshot.copy()))
    }
    await contextQueue.enqueue(.deletion(where: Predicate<PlanModel>.true))
    await contextQueue.enqueue(.deletion(where: Predicate<GoalModel>.true))
    await contextQueue.enqueue(.deletion(where: Predicate<ToDoModel>.true))
    try await contextQueue.run { contextQueue in
      try await contextQueue.flush()
      let plans = try contextQueue.fetch(.all, where: Predicate<PlanModel>.true)
      let goals = try contextQueue.fetch(.all, where: Predicate<GoalModel>.true)
      let toDos = try contextQueue.fetch(.all, where: Predicate<ToDoModel>.true)
      #expect(plans.isEmpty)
      #expect(goals.isEmpty)
      #expect(toDos.isEmpty)
    }
  }
}
