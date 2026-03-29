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

import SwiftData

/// Abstraction for accessing a container in which ``CorePlanner`` structures
/// are inserted, with the stored data being retrievable after deinitialization
/// of this class or the underlying implementations of ``CorePlanner/Plan``,
/// ``CorePlanner/Goal`` and ``CorePlanner/ToDo``.
public class PersistentPlanRepository {
  /// ``ModelContextQueue`` by which all standalone and batched operations are
  /// performed.
  public let contextQueue: ModelContextQueue

  /// Plans in this repository.
  ///
  /// ###### Implementation notes
  ///
  /// The plans *must* be sorted and, even though this is an array, each of them
  /// *must* be unique, at least with an ID distinct from that of the other
  /// ones. Such uniqueness *must* be ensured by the public initializer or
  /// factory function.
  public var plans: [PersistedPlan] {
    get async throws {
      try await contextQueue.run { contextQueue in
        try contextQueue.fetch(.all, where: Predicate<PlanModel>.true)
          .map { model in Snapshot(of: model) }
      }
      .asyncMap { modelSnapshot in
        try await .init(
          identifiedAs: modelSnapshot.copy().uuid,
          insertedInto: contextQueue
        )
      }
    }
  }

  /// Container on which the ``context`` is based.
  private let container: ModelContainer

  /// Types of models insertable into this repository.
  public static let modelTypes: [any PersistentModel.Type] = [
    PlanModel.self, GoalModel.self, ToDoModel.self
  ]

  /// Initializes a persistent repository of plans.
  ///
  /// - Parameter isInMemory: Whether plans, goals and to-dos are stored in
  ///   memory rather than in a database.
  public init(inMemory isInMemory: Bool) throws {
    self.container = try Self.makeContainer(isInMemory: isInMemory)
    self.contextQueue = .init(container: container)
  }

  /// Adds a plan as described by its descriptor. All goals described in it,
  /// alongside the to-dos defined within these goals, will also be added.
  ///
  /// ###### Implementation notes
  ///
  /// The array returned by ``plans`` *must* have been modified after a call to
  /// this function, with the plan included in it. By the time this function
  /// returns, such array *must* be sorted according to the criteria of
  /// comparison of the type of plan.
  ///
  /// - Parameter descriptor: Descriptor based on which the plan will be
  ///   added.
  /// - Returns: The ID of the added plan.
  /// - SeeAlso: ``addGoal(describedBy:)``
  public func addPlan(
    describedBy descriptor: AnyPlanDescriptor
  ) async throws -> UUID {
    try await contextQueue.run { contextQueue in
      let model = PlanModel(describedBy: descriptor)
      let planUUID = model.uuid
      if descriptor.goals.isEmpty {
        contextQueue.enqueue(.insertion(of: model))
      } else {
        contextQueue.enqueue(.insertion(of: model))
        for goalDescriptor in descriptor.goals {
          let goalModel = GoalModel(
            describedBy: goalDescriptor,
            planUUID: planUUID
          )
          contextQueue.enqueue(.insertion(of: goalModel))
          for toDoDescriptor in goalDescriptor.toDos {
            contextQueue.enqueue(
              .insertion(
                of: ToDoModel(
                  describedBy: toDoDescriptor,
                  goalUUID: goalModel.uuid
                )
              )
            )
          }
        }
      }
      try await contextQueue.flush()
      return model.uuid
    }
  }

  /// Retrieves an added plan identified with a given ID.
  ///
  /// - Parameter id: ID of the plan to be retrieved.
  /// - Throws: If the plan is not found.
  public func plan(identifiedAs id: UUID) async throws -> PersistedPlan {
    try await .init(identifiedAs: id, insertedInto: contextQueue)
  }

  /// Removes an added plan from this repository.
  ///
  /// ###### Implementation notes
  ///
  /// The array returned by ``plans`` *must* have been modified after a call to
  /// this function, with the plan removed from it. By the time this function
  /// returns, such array *must* be sorted according to the criteria of
  /// comparison of the type of plan.
  ///
  /// - Parameter id: ID of the plan to be deleted.
  public func removePlan(identifiedAs id: UUID) async throws {
    try await contextQueue.run { contextQueue in
      contextQueue.enqueue(
        .deletion(where: #Predicate<PlanModel> { model in model.uuid == id })
      )
      try await contextQueue.flush()
    }
  }

  /// Removes every added plan, goal and to-do from this repository.
  ///
  /// > Warning: This is a destructive action and cannot be undone.
  public func clear() throws { try container.erase() }

  /// Produces a container into which models of persisted implementations of
  /// ``CorePlanner`` are inserted.
  static func makeContainer(isInMemory: Bool) throws -> ModelContainer {
    try .init(
      for: .init(Self.modelTypes),
      configurations: .init(isStoredInMemoryOnly: isInMemory)
    )
  }
}

/// Plan persisted into a container by a ``PersistentPlanRepository``.
public final class PersistedPlan: PersistedDomain, Plan {
  public typealias Descriptor = AnyPlanDescriptor
  public typealias BackingModel = PlanModel

  public let contextQueue: ModelContextQueue
  public let id: UUID
  public var headline: Headline

  public var goals: [PersistedGoal] {
    get async throws {
      try await contextQueue.run { context in
        try context.fetch(
          .all,
          where: #Predicate<GoalModel> { goalModel in goalModel.planUUID == id }
        )
        .map(\.uuid)
      }
      .asyncMap { goalID in
        try await .init(identifiedAs: goalID, insertedInto: contextQueue)
      }
    }
  }

  public static let description = "plan"

  public init(
    identifiedAs id: UUID,
    insertedInto context: ModelContextQueue
  ) async throws {
    self.id = id
    self.contextQueue = context
    let backingModel = try await Self.backingModel(
      identifiedAs: id,
      insertedInto: context
    )
    self.headline = .from(
      title: backingModel.title,
      summary: backingModel.summary
    )
  }

  public func addGoal(
    describedBy descriptor: AnyGoalDescriptor
  ) async throws -> UUID {
    try await contextQueue.run { [id] contextQueue in
      let goalModel = GoalModel(describedBy: descriptor, planUUID: id)
      let goalUUID = goalModel.uuid
      if descriptor.toDos.isEmpty {
        contextQueue.enqueue(.insertion(of: goalModel))
      } else {
        for toDoDescriptor in descriptor.toDos {
          let toDoModel = ToDoModel(
            describedBy: toDoDescriptor,
            goalUUID: goalUUID
          )
          contextQueue.enqueue(.insertion(of: toDoModel))
        }
      }
      try await contextQueue.flush()
      return goalUUID
    }
  }

  public func goal(identifiedAs id: UUID) async throws -> PersistedGoal {
    try await .init(identifiedAs: id, insertedInto: contextQueue)
  }

  public func removeGoal(identifiedAs id: UUID) async throws {
    try await contextQueue.run { contextQueue in
      contextQueue.enqueue(
        .deletion(
          where: #Predicate<GoalModel> { goalModel in goalModel.uuid == id }
        )
      )
      try await contextQueue.flush()
    }
  }
}

extension PersistedPlan: Hashable {
  public func hash(into hasher: inout Hasher) {
    id.hash(into: &hasher)
    title.hash(into: &hasher)
    summary.hash(into: &hasher)
  }
}

/// Model of a plan persisted into a container by a
/// ``PersistentPlanRepository``.
@Model
public final class PlanModel: PartialHeadlined {
  private(set) public var uuid = UUID()

  private(set) fileprivate var title: String
  fileprivate var summary: String

  public static var titleKeyPath: KeyPath<PlanModel, String> { \.title }
  public static var summaryKeyPath: KeyPath<PlanModel, String> { \.summary }

  convenience init(describedBy descriptor: AnyPlanDescriptor) {
    self.init(
      uuid: .init(),
      title: descriptor.title,
      summary: descriptor.summary
    )
  }

  required init(uuid: UUID, title: String, summary: String) {
    self.uuid = uuid
    self.title = title
    self.summary = summary
  }
}

extension PlanModel: NSCopying {
  public func copy(with zone: NSZone? = nil) -> Any {
    Self(uuid: uuid, title: title, summary: summary)
  }
}

/// Goal persisted into a container by its ``PersistedPlan``.
public final class PersistedGoal: PersistedDomain, Goal {
  public typealias Descriptor = AnyGoalDescriptor
  public typealias BackingModel = GoalModel

  public let contextQueue: ModelContextQueue
  public let id: UUID
  public var headline: Headline

  public var toDos: [PersistedToDo] {
    get async throws {
      try await contextQueue.run { [id] context in
        try context.fetch(
          .all,
          where: #Predicate<ToDoModel> { toDoModel in toDoModel.goalUUID == id }
        )
        .map(\.uuid)
      }
      .asyncMap { toDoID in
        try await .init(identifiedAs: toDoID, insertedInto: contextQueue)
      }
    }
  }

  public static let description = "goal"

  public init(
    identifiedAs id: UUID,
    insertedInto context: ModelContextQueue
  ) async throws {
    self.id = id
    self.contextQueue = context
    let backingModel = try await Self.backingModel(
      identifiedAs: id,
      insertedInto: context
    )
    self.headline = .from(
      title: backingModel.title,
      summary: backingModel.summary
    )
  }

  public func addToDo(
    describedBy descriptor: AnyToDoDescriptor
  ) async throws -> UUID {
    try await contextQueue.run { [id] contextQueue in
      let toDoModel = ToDoModel(describedBy: descriptor, goalUUID: id)
      contextQueue.enqueue(.insertion(of: toDoModel))
      try await contextQueue.flush()
      return toDoModel.uuid
    }
  }

  public func toDo(identifiedAs id: UUID) async throws -> PersistedToDo {
    try await .init(identifiedAs: id, insertedInto: contextQueue)
  }

  public func removeToDo(identifiedAs id: UUID) async throws {
    try await contextQueue.run { contextQueue in
      contextQueue.enqueue(
        .deletion(
          where: #Predicate<ToDoModel> { toDoModel in toDoModel.uuid == id }
        )
      )
      try await contextQueue.flush()
    }
  }
}

extension PersistedGoal: Hashable {
  public func hash(into hasher: inout Hasher) {
    id.hash(into: &hasher)
    title.hash(into: &hasher)
    summary.hash(into: &hasher)
  }
}

/// Model of a goal persisted into a container by its ``PersistedPlan``.
@Model
public final class GoalModel: PartialHeadlined {
  private(set) public var uuid: UUID

  private(set) fileprivate var planUUID: UUID
  private(set) fileprivate var title: String
  private(set) fileprivate var summary: String

  public static var titleKeyPath: KeyPath<GoalModel, String> { \.title }
  public static var summaryKeyPath: KeyPath<GoalModel, String> { \.summary }

  fileprivate convenience init(
    describedBy descriptor: AnyGoalDescriptor,
    planUUID: UUID
  ) {
    self.init(
      uuid: .init(),
      planUUID: planUUID,
      title: descriptor.title,
      summary: descriptor.summary
    )
  }

  required init(uuid: UUID, planUUID: UUID, title: String, summary: String) {
    self.uuid = uuid
    self.planUUID = planUUID
    self.title = title
    self.summary = summary
  }
}

extension GoalModel: NSCopying {
  public func copy(with zone: NSZone? = nil) -> Any {
    Self(uuid: uuid, planUUID: planUUID, title: title, summary: summary)
  }
}

/// To-do persisted into a container by its ``PersistedGoal``.
public final class PersistedToDo: PersistedDomain, ToDo {
  public typealias Descriptor = AnyToDoDescriptor
  public typealias BackingModel = ToDoModel

  public let contextQueue: ModelContextQueue
  public let id: UUID
  public var headline: Headline
  public var status: Status
  public var deadline: Date

  public static let description = "to-do"

  public init(
    identifiedAs id: UUID,
    insertedInto context: ModelContextQueue
  ) async throws {
    self.id = id
    self.contextQueue = context
    let backingModel = try await Self.backingModel(
      identifiedAs: id,
      insertedInto: context
    )
    self.headline = .from(
      title: backingModel.title,
      summary: backingModel.summary
    )
    self.status = backingModel.status
    self.deadline = backingModel.deadline
  }

  public func setStatus(to newStatus: Status) async throws {
    try await backingModel.setValue(forKey: \.status, to: newStatus)
  }

  public func setDeadline(to newDeadline: Date) async throws {
    try await backingModel.setValue(forKey: \.deadline, to: newDeadline)
  }
}

extension PersistedToDo: Hashable {
  public func hash(into hasher: inout Hasher) {
    id.hash(into: &hasher)
    title.hash(into: &hasher)
    summary.hash(into: &hasher)
    status.hash(into: &hasher)
    deadline.hash(into: &hasher)
  }
}

/// Model of a to-do persisted into a container by its ``PersistedGoal``.
@Model
public final class ToDoModel: PartialHeadlined {
  private(set) public var uuid: UUID

  private(set) fileprivate var goalUUID: UUID
  private(set) fileprivate var title: String
  private(set) fileprivate var summary: String
  private(set) fileprivate var status: Status
  private(set) fileprivate var deadline: Date

  public static var titleKeyPath: KeyPath<ToDoModel, String> { \.title }
  public static var summaryKeyPath: KeyPath<ToDoModel, String> { \.summary }

  fileprivate convenience init(
    describedBy descriptor: AnyToDoDescriptor,
    goalUUID: UUID
  ) {
    self.init(
      uuid: .init(),
      goalUUID: goalUUID,
      title: descriptor.title,
      summary: descriptor.summary,
      status: descriptor.status,
      deadline: descriptor.deadline
    )
  }

  required init(
    uuid: UUID,
    goalUUID: UUID,
    title: String,
    summary: String,
    status: Status,
    deadline: Date
  ) {
    self.uuid = uuid
    self.goalUUID = goalUUID
    self.title = title
    self.summary = summary
    self.status = status
    self.deadline = deadline
  }
}

extension ToDoModel: NSCopying {
  public func copy(with zone: NSZone? = nil) -> Any {
    Self(
      uuid: uuid,
      goalUUID: goalUUID,
      title: title,
      summary: summary,
      status: status,
      deadline: deadline
    )
  }
}

/// Protocol common to ``CorePlanner``-related types supporting persistence
/// backed by the SwiftData framework.
///
/// Conforming to this protocol includes support for normalization of the
/// headline of the model (upon both initialization and changes through the
/// setters) and domain-driven behavior, e.g., adding to-dos to goals and goals
/// to plans, without exposing details about the underlying persistence layer.
public protocol PersistedDomain: Headlineable where ID == UUID {
  /// The persisted model on which this structure is based.
  associatedtype BackingModel: PartialHeadlined, PersistentModel, NSCopying

  /// ``ModelContextQueue`` of the model backing this implementation.
  var contextQueue: ModelContextQueue { get }

  /// Makes an instance of this type from the ID of the model persisted into the
  /// container, backing accesses to each of its properties, adding
  /// normalization to the headline of such model and overall domain-driven
  /// behavior (e.g., adding to-dos to goals and goals to plans).
  ///
  /// - Parameters:
  ///   - id: The stable identity of the entity associated with this instance.
  ///   - context: ``ModelContextQueue`` into which the model is inserted.
  init(
    identifiedAs id: UUID,
    insertedInto contextQueue: ModelContextQueue
  ) async throws
}

extension PersistedDomain {
  /// Copy of the object persisted into the container and on which the headline
  /// of this implementation is based.
  ///
  /// - SeeAlso: ``backingModel(identifiedAs:insertedInto:)``
  fileprivate var backingModel: BackingModel {
    get async throws {
      try await Self.backingModel(identifiedAs: id, insertedInto: contextQueue)
    }
  }

  /// Retrieves a copy of the object persisted into the container and on which
  /// the headline of this implementation is based.
  ///
  /// ###### Implementation notes
  ///
  /// The backing model is retrieved from the ``context`` by copy through a
  /// snapshot. This is far from ideal, given that copying is not synchronized
  /// and may be made outdated due to changes by another caller.
  ///
  /// In a greater, more complex program, this could be an issue, and this
  /// function would (maybe) have to be declared with a sendable closure to
  /// which the backing model is provided; in our situation, however, this
  /// detail will probably do no harm.
  ///
  /// - Parameters:
  ///   - uuid: The ID of the backing model.
  ///   - context: ``ModelContextQueue`` into which the backing model is
  ///     inserted.
  /// - SeeAlso: ``backingModel``
  fileprivate static func backingModel(
    identifiedAs id: UUID,
    insertedInto contextQueue: ModelContextQueue
  ) async throws -> BackingModel {
    let snapshot = try await contextQueue.run { context in
      guard
        let backingModel = try context.fetch(
          .one,
          where: #Predicate<BackingModel> { backingModel in
            backingModel.uuid == id
          }
        )
      else { throw PlannerError.nonexistent(type: Self.self, id: id) }
      return Snapshot(of: backingModel)
    }
    return snapshot.copy()
  }
}

extension PersistedDomain where Self: Headlineable {
  public func setTitle(to newTitle: String) async throws {
    var newTitle = newTitle
    normalize(title: &newTitle)
    try await backingModel.setValue(
      forKey: BackingModel.titleKeyPath,
      to: newTitle
    )
  }

  public func setSummary(to newSummary: String) async throws {
    var newSummary = newSummary
    normalize(summary: &newSummary)
    try await backingModel.setValue(
      forKey: BackingModel.summaryKeyPath,
      to: newSummary
    )
  }
}

/// Protocol to which each model of a ``CorePlanner`` structure conforms,
/// indicating that such model is titled and summarized. The partiality is due
/// to neither its title nor its summary having been normalized, which denotes
/// that they may be deemed invalid by an actual `Headlined`.
public protocol PartialHeadlined {
  /// The stable identifier of this structure, safely-usable accross model contexts.
  ///
  /// This likely goes against
  /// [*The Laws of Core Data*](https://davedelong.com/blog/2018/05/09/the-laws-of-core-data)
  /// formulated by Dave DeLong, but acts as a workaround for some fetching
  /// problems the author of Pragma was having (due to a skill issue).
  var uuid: UUID { get }

  /// Key path of the title.
  static var titleKeyPath: KeyPath<Self, String> { get }

  /// Key path of the description.
  static var summaryKeyPath: KeyPath<Self, String> { get }
}
