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
import SwiftData
import Testing

struct ConcurrentContextTests {
  @Suite("Batching")
  struct BatchingTests {
    @Test
    func doesNotSaveWhileBatchingInsertion() async throws {
      try await ConcurrentContext(container: PersistentPlanner.makeContainer(isInMemory: true))
        .run { context in
          try context.transaction { context in
            try context.insert(PlanModel(uuid: .init(), title: "", abstract: ""))
            let fetchedModel = try context.fetch(.one, where: Predicate<PlanModel>.true)
            #expect(fetchedModel == nil)
          }
        }
    }

    @Test
    func doesNotSaveWhileBatchingDeletion() async throws {
      let context =
        try ConcurrentContext(container: PersistentPlanner.makeContainer(isInMemory: true))
      let insertedModel = PlanModel(uuid: .init(), title: "", abstract: "")
      let insertedModelSnapshot = Snapshot(of: insertedModel)
      try await context.insert(insertedModel)
      try await context.transaction { context in
        let copiedInsertedModel = insertedModelSnapshot.copy()
        try context.delete(copiedInsertedModel)
        let fetchedModel = try context.fetch(.one, where: Predicate<PlanModel>.true)
        #expect(fetchedModel?.uuid == copiedInsertedModel.uuid)
      }
    }

    @Test
    func savesAfterBatchingInsertion() async throws {
      let context =
        try ConcurrentContext(container: PersistentPlanner.makeContainer(isInMemory: true))
      let insertedModelSnapshot = Snapshot(of: PlanModel(uuid: .init(), title: "", abstract: ""))
      try await context.transaction { context in
        try context.insert(insertedModelSnapshot.copy())
      }
      try await context.run { context in
        let copiedInsertedModel = insertedModelSnapshot.copy()
        let fetchedModel = try context.fetch(.one, where: Predicate<PlanModel>.true)
        #expect(fetchedModel?.uuid == copiedInsertedModel.uuid)
      }
    }

    @Test
    func savesAfterBatchingDeletion() async throws {
      let context =
        try ConcurrentContext(container: PersistentPlanner.makeContainer(isInMemory: true))
      let insertedModelUUID = UUID()
      try await context.insert(PlanModel(uuid: insertedModelUUID, title: "", abstract: ""))
      try await context.transaction { context in
        try context.delete(
          where: #Predicate<PlanModel> { model in model.uuid == insertedModelUUID }
        )
      }
      try await context.run { context in
        let fetchedModel = try context.fetch(.one, where: Predicate<PlanModel>.true)
        #expect(fetchedModel == nil)
      }
    }
  }

  @Suite("Fetching")
  struct FetchingTests {
    @Test
    func fetchingOneNonexistentModelReturnsNil() async throws {
      try await ConcurrentContext(container: PersistentPlanner.makeContainer(isInMemory: true))
        .run { context in
          let fetchedModel = try context.fetch(.one, where: Predicate<PlanModel>.true)
          #expect(fetchedModel == nil)
        }
    }

    @Test
    func fetchesOneExistingModel() async throws {
      try await ConcurrentContext(container: PersistentPlanner.makeContainer(isInMemory: true))
        .run { context in
          let insertedModel = PlanModel(uuid: .init(), title: "", abstract: "")
          try context.insert(insertedModel)
          let fetchedModel = try context.fetch(.one, where: Predicate<PlanModel>.true)
          #expect(fetchedModel == insertedModel)
        }
    }

    @Test
    func fetchesAllModels() async throws {
      try await ConcurrentContext(container: PersistentPlanner.makeContainer(isInMemory: true))
        .run { context in
          let insertedModels =
            [PlanModel](count: 128) { _ in .init(uuid: .init(), title: "", abstract: "") }
          for insertedModel in insertedModels { try context.insert(insertedModel) }
          let fetchedModels = try context.fetch(.all, where: Predicate<PlanModel>.true)
          #expect(fetchedModels == insertedModels)
        }
    }
  }

  @Test
  func inserts() async throws {
    try await ConcurrentContext(container: PersistentPlanner.makeContainer(isInMemory: true)).run {
      context in
      let model = PlanModel(uuid: .init(), title: "", abstract: "")
      try context.insert(model)
      let models = try context.fetch(where: Predicate<PlanModel>.true)
      #expect(models.elementsEqual([model]))
    }
  }

  @Test
  func deletes() async throws {
    try await ConcurrentContext(container: PersistentPlanner.makeContainer(isInMemory: true)).run {
      context in
      let model = PlanModel(uuid: .init(), title: "", abstract: "")
      try context.insert(model)
      try context.delete(model)
      let models = try context.fetch(where: Predicate<PlanModel>.true)
      #expect(models.isEmpty)
    }
  }

  @Test
  func deletesAllOfSomeType() async throws {
    let context =
      try ConcurrentContext(container: PersistentPlanner.makeContainer(isInMemory: true))
    let planSnapshots = [Snapshot<PlanModel>](count: 2) { _ in
      .init(of: .init(uuid: .init(), title: "", abstract: ""))
    }
    let goalSnapshots = planSnapshots.map { planSnapshot in
      Snapshot(
        of: GoalModel(uuid: .init(), planUUID: planSnapshot.copy().uuid, title: "", abstract: "")
      )
    }
    let toDoSnapshots = goalSnapshots.map { goalSnapshot in
      Snapshot(
        of: ToDoModel(
          uuid: .init(),
          goalUUID: goalSnapshot.copy().uuid,
          title: "",
          abstract: "",
          status: .idle,
          deadline: .distantFuture
        )
      )
    }
    for planSnapshot in planSnapshots { try await context.insert(planSnapshot.copy()) }
    for goalSnapshot in goalSnapshots { try await context.insert(goalSnapshot.copy()) }
    for toDoSnapshot in toDoSnapshots { try await context.insert(toDoSnapshot.copy()) }
    try await context.deleteAll(ofType: PlanModel.self)
    try await context.deleteAll(ofType: GoalModel.self)
    try await context.deleteAll(ofType: ToDoModel.self)
    try await context.run { context in
      let plans = try context.fetch(where: Predicate<PlanModel>.true)
      let goals = try context.fetch(where: Predicate<GoalModel>.true)
      let toDos = try context.fetch(where: Predicate<ToDoModel>.true)
      #expect(plans.isEmpty)
      #expect(goals.isEmpty)
      #expect(toDos.isEmpty)
    }
  }
}
