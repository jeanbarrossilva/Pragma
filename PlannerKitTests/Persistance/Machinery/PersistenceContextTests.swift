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

struct PersistenceContextTests {
  @Suite("Batching")
  struct BatchingTests {
    @Test
    func doesNotSaveWhileBatchingInsertion() async throws {
      try await PersistenceContext(isInMemory: true).run { context in
        try context.batch { context in
          try context.insert(PlanModel(uuid: .init(), title: "", abstract: ""))
          let fetchedModel = try context.fetch(.one, where: Predicate<PlanModel>.true)
          #expect(fetchedModel == nil)
        }
      }
    }

    @Test
    func doesNotSaveWhileBatchingDeletion() async throws {
      let context = try PersistenceContext(isInMemory: true)
      let insertedModel = PlanModel(uuid: .init(), title: "", abstract: "")
      let insertedModelSnapshot = Snapshot(of: insertedModel)
      try await context.insert(insertedModel)
      try await context.batch { context in
        let copiedInsertedModel = insertedModelSnapshot.copy()
        try context.delete(copiedInsertedModel)
        let fetchedModel = try context.fetch(.one, where: Predicate<PlanModel>.true)
        #expect(fetchedModel?.uuid == copiedInsertedModel.uuid)
      }
    }

    @Test
    func savesAfterBatchingInsertion() async throws {
      let context = try PersistenceContext(isInMemory: true)
      let insertedModelSnapshot = Snapshot(of: PlanModel(uuid: .init(), title: "", abstract: ""))
      try await context.batch { context in
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
      let context = try PersistenceContext(isInMemory: true)
      let insertedModelUUID = UUID()
      try await context.insert(PlanModel(uuid: insertedModelUUID, title: "", abstract: ""))
      try await context.batch { context in
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
      try await PersistenceContext(isInMemory: true).run { context in
        let fetchedModel = try context.fetch(.one, where: Predicate<PlanModel>.true)
        #expect(fetchedModel == nil)
      }
    }

    @Test
    func fetchesOneExistingModel() async throws {
      try await PersistenceContext(isInMemory: true).run { context in
        let insertedModel = PlanModel(uuid: .init(), title: "", abstract: "")
        try context.insert(insertedModel)
        let fetchedModel = try context.fetch(.one, where: Predicate<PlanModel>.true)
        #expect(fetchedModel == insertedModel)
      }
    }

    @Test
    func fetchesAllModels() async throws {
      try await PersistenceContext(isInMemory: true).run { context in
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
    try await PersistenceContext(isInMemory: true).run { context in
      let model = PlanModel(uuid: .init(), title: "", abstract: "")
      try context.insert(model)
      let models = try context.fetch(where: Predicate<PlanModel>.true)
      #expect(models.elementsEqual([model]))
    }
  }

  @Test
  func deletes() async throws {
    try await PersistenceContext(isInMemory: true).run { context in
      let model = PlanModel(uuid: .init(), title: "", abstract: "")
      try context.insert(model)
      try context.delete(model)
      let models = try context.fetch(where: Predicate<PlanModel>.true)
      #expect(models.isEmpty)
    }
  }

  @Test
  func clears() async throws {
    let context = try PersistenceContext(isInMemory: true)
    let plan = PlanModel(uuid: .init(), title: "", abstract: "")
    let goal = GoalModel(uuid: .init(), planUUID: plan.uuid, title: "", abstract: "")
    let toDo = ToDoModel(
      uuid: .init(),
      goalUUID: goal.uuid,
      title: "",
      abstract: "",
      status: .idle,
      deadline: .distantFuture
    )
    try await context.insert(plan)
    try await context.insert(goal)
    try await context.insert(toDo)
    try await context.clear()
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
