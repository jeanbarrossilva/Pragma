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

import SwiftData

extension Planner where Self == PersistentPlanner {
  /// Alias for the initialization of a ``PersistentPlanner``.
  public static var persistent: PersistentPlanner {
    get throws(SwiftDataError) { try persistent(isInMemory: false) }
  }

  /// Produces an instance of a ``PersistentPlanner``.
  ///
  /// - Parameter isInMemory: Whether plans, goals and to-dos are stored in memory, as opposed to
  ///   persisted.
  static func persistent(isInMemory: Bool) throws(SwiftDataError) -> Self {
    try PersistentPlanner(isInMemory: isInMemory)
  }
}

/// Abstraction for accessing a container in which ``CorePlanner`` structures are inserted, with
/// the stored data being retrievable after deinitialization of this class or the underlying
/// implementations of ``CorePlanner/Plan``, ``CorePlanner/Goal`` and ``CorePlanner/ToDo``.
public struct PersistentPlanner: Planner {
  /// Context by which all standalone and batched operations are performed.
  public let context: PersistenceContext

  /// Types of models insertable into this planner.
  public static let modelTypes = PersistenceContext.modelTypes

  fileprivate init(isInMemory: Bool) throws(SwiftDataError) {
    self.context = try .init(isInMemory: isInMemory)
  }

  public mutating func addPlan(
    describedBy descriptor: AnyPlanDescriptor
  ) async throws -> UUID {
    try await context.run { context in
      let model = PlanModel(describedBy: descriptor)
      let modelUUID = model.uuid
      if descriptor.goals.isEmpty {
        try context.insert(model)
      } else {
        try context.batch { context in
          for goalDescriptor in descriptor.goals {
            let goalModel = GoalModel(describedBy: goalDescriptor, planUUID: modelUUID)
            try context.insert(goalModel)
            for toDoDescriptor in goalDescriptor.toDos {
              try context.insert(
                ToDoModel(describedBy: toDoDescriptor, goalUUID: goalModel.uuid)
              )
            }
          }
        }
      }
      return modelUUID
    }
  }

  public func withPlans<Result>(
    _ action: @Sendable (borrowing OwnedArray<PersistedPlan>) async throws -> Result
  ) async throws -> Result where Result: Sendable {
    try await context.run { context in
      let models = try context.fetch(.all, where: Predicate<PlanModel>.true)
      var plans = OwnedArray<PersistedPlan>(capacity: models.count)
      for model in models {
        let plan = try await PersistedPlan(identifiedAs: model.uuid, insertedInto: context)
        plans.append(plan)
      }
      return try await action(plans)
    }
  }

  public func withPlan<Result>(
    identifiedAs id: UUID,
    _ action: @Sendable (borrowing PersistedPlan) async throws -> Result
  ) async throws -> Result where Result: Sendable {
    try await context.run { context in
      guard let model = try context.fetch(.one, where: Predicate<PlanModel>.true) else {
        throw PlannerError<SwiftDataError>.nonexistent(type: PersistedPlan.self, id: id)
      }
      let plan = try await PersistedPlan(identifiedAs: model.uuid, insertedInto: context)
      return try await action(plan)
    }
  }

  public mutating func removePlan(
    identifiedAs id: UUID
  ) async throws {
    try await context.delete(where: #Predicate<PlanModel> { model in model.uuid == id })
  }

  public consuming func clear() async throws {
    try await context.clear()
  }
}

/// Plan persisted into a container by a ``PersistentPlanner``.
public final class PersistedPlan: PersistedDomain, Plan {
  public typealias BackingModel = PlanModel

  public let context: PersistenceContext
  public let id: UUID
  public let title: String
  public let abstract: String

  public var goals: [PersistedGoal] {
    get async throws {
      try await context.run { context in
        try await context
          .fetch(where: #Predicate<GoalModel> { goalModel in goalModel.planUUID == id })
          .asyncMap { goalModel in
            try await .init(identifiedAs: goalModel.uuid, insertedInto: context)
          }
      }
    }
  }

  public init(
    identifiedAs id: UUID,
    insertedInto context: PersistenceContext
  ) async throws {
    self.id = id
    self.context = context
    let backingModel = try await Self.backingModel(identifiedAs: id, insertedInto: context)
    var title = backingModel.title
    normalize(title: &title)
    self.title = title
    var abstract = backingModel.abstract
    normalize(abstract: &abstract)
    self.abstract = abstract
  }

  public func addGoal(
    describedBy descriptor: AnyGoalDescriptor
  ) async throws -> UUID {
    try await context.run { context in
      let goalModel = GoalModel(describedBy: descriptor, planUUID: id)
      let goalModelUUID = goalModel.uuid
      if descriptor.toDos.isEmpty {
        try context.insert(goalModel)
      } else {
        try context.batch { context in
          for toDoDescriptor in descriptor.toDos {
            let toDoModel = ToDoModel(describedBy: toDoDescriptor, goalUUID: goalModelUUID)
            try context.insert(toDoModel)
          }
        }
      }
      return goalModelUUID
    }
  }

  public func withGoals<Result>(
    _ action: @Sendable (borrowing OwnedArray<PersistedGoal>) async throws -> Result
  ) async throws -> Result where Result: Sendable {
    try await context.run { context in
      let goalModels = try context.fetch(.all, where: Predicate<GoalModel>.true)
      var goals = OwnedArray<PersistedGoal>(capacity: goalModels.count)
      for goalModel in goalModels {
        let goal = try await PersistedGoal(identifiedAs: goalModel.uuid, insertedInto: context)
        goals.append(goal)
      }
      return try await action(goals)
    }
  }

  public func withGoal<Result>(
    identifiedAs id: UUID,
    _ action: @Sendable (borrowing PersistedGoal) async throws -> Result
  ) async throws -> Result where Result: Sendable {
    try await context.run { context in
      guard let goalModel = try context.fetch(.one, where: Predicate<GoalModel>.true) else {
        throw PlannerError<SwiftDataError>.nonexistent(type: PersistedGoal.self, id: id)
      }
      let goal = try await PersistedGoal(identifiedAs: goalModel.uuid, insertedInto: context)
      return try await action(goal)
    }
  }

  public func removeGoal(identifiedAs id: UUID) async throws {
    try await context.delete(where: #Predicate<GoalModel> { goalModel in goalModel.uuid == id })
  }
}

extension PersistedPlan: Hashable {
  public func hash(into hasher: inout Hasher) {
    id.hash(into: &hasher)
    title.hash(into: &hasher)
    abstract.hash(into: &hasher)
  }
}

/// Model of a plan persisted into a container by a ``PersistentPlanner``.
@Model
public final class PlanModel: PartialHeadlined {
  private(set) public var uuid = UUID()

  private(set) fileprivate var title: String
  fileprivate var abstract: String

  public static var titleKeyPath: KeyPath<PlanModel, String> { \.title }
  public static var abstractKeyPath: KeyPath<PlanModel, String> { \.abstract }

  convenience init(describedBy descriptor: AnyPlanDescriptor) {
    self.init(uuid: .init(), title: descriptor.title, abstract: descriptor.abstract)
  }

  required init(uuid: UUID, title: String, abstract: String) {
    self.uuid = uuid
    self.title = title
    self.abstract = abstract
  }
}

extension PlanModel: NSCopying {
  public func copy(with zone: NSZone? = nil) -> Any {
    Self(uuid: uuid, title: title, abstract: abstract)
  }
}

/// Goal persisted into a container by its ``PersistedPlan``.
public final class PersistedGoal: PersistedDomain, Goal {
  public typealias BackingModel = GoalModel

  public let context: PersistenceContext
  public let id: UUID
  public let title: String
  public let abstract: String

  public init(
    identifiedAs id: UUID,
    insertedInto context: PersistenceContext
  ) async throws {
    self.id = id
    self.context = context
    let backingModel = try await Self.backingModel(identifiedAs: id, insertedInto: context)
    var title = backingModel.title
    normalize(title: &title)
    self.title = title
    var abstract = backingModel.abstract
    normalize(abstract: &abstract)
    self.abstract = abstract
  }

  public func addToDo(
    describedBy descriptor: AnyToDoDescriptor
  ) async throws -> UUID {
    try await context.run { context in
      let toDoModel = ToDoModel(describedBy: descriptor, goalUUID: id)
      try context.insert(toDoModel)
      return toDoModel.uuid
    }
  }

  public func withToDos<Result>(
    _ action: @Sendable (borrowing OwnedArray<PersistedToDo>) async throws -> Result
  ) async throws -> Result where Result: Sendable {
    try await context.run { context in
      let toDoModels = try context.fetch(.all, where: Predicate<GoalModel>.true)
      var toDos = OwnedArray<PersistedToDo>(capacity: toDoModels.count)
      for toDoModel in toDoModels {
        let toDo = try await PersistedToDo(identifiedAs: toDoModel.uuid, insertedInto: context)
        toDos.append(toDo)
      }
      return try await action(toDos)
    }
  }

  public func withToDo<Result>(
    identifiedAs id: UUID,
    _ action: @Sendable (borrowing PersistedToDo) async throws -> Result
  ) async throws -> Result where Result: Sendable {
    try await context.run { context in
      guard let toDoModel = try context.fetch(.one, where: Predicate<ToDoModel>.true)
      else { throw PlannerError<SwiftDataError>.nonexistent(type: PersistedToDo.self, id: id) }
      let toDo = try await PersistedToDo(identifiedAs: toDoModel.uuid, insertedInto: context)
      return try await action(toDo)
    }
  }

  public func removeToDo(identifiedAs id: UUID) async throws {
    try await context.delete(where: #Predicate<ToDoModel> { toDoModel in toDoModel.uuid == id })
  }
}

extension PersistedGoal: Hashable {
  public func hash(into hasher: inout Hasher) {
    id.hash(into: &hasher)
    title.hash(into: &hasher)
    abstract.hash(into: &hasher)
  }
}

/// Model of a goal persisted into a container by its ``PersistedPlan``.
@Model
public final class GoalModel: PartialHeadlined {
  private(set) public var uuid: UUID

  private(set) fileprivate var planUUID: UUID
  private(set) fileprivate var title: String
  private(set) fileprivate var abstract: String

  public static var titleKeyPath: KeyPath<GoalModel, String> { \.title }
  public static var abstractKeyPath: KeyPath<GoalModel, String> { \.abstract }

  fileprivate convenience init(describedBy descriptor: AnyGoalDescriptor, planUUID: UUID) {
    self.init(
      uuid: .init(),
      planUUID: planUUID,
      title: descriptor.title,
      abstract: descriptor.abstract
    )
  }

  required init(uuid: UUID, planUUID: UUID, title: String, abstract: String) {
    self.uuid = uuid
    self.planUUID = planUUID
    self.title = title
    self.abstract = abstract
  }
}

extension GoalModel: NSCopying {
  public func copy(with zone: NSZone? = nil) -> Any {
    Self(uuid: uuid, planUUID: planUUID, title: title, abstract: abstract)
  }
}

/// To-do persisted into a container by its ``PersistedGoal``.
public final class PersistedToDo: PersistedDomain, ToDo {
  public typealias BackingModel = ToDoModel

  public let context: PersistenceContext
  public let id: UUID
  public let title: String
  public let abstract: String
  public let status: Status
  public let deadline: Date

  public init(
    identifiedAs id: UUID,
    insertedInto context: PersistenceContext
  ) async throws {
    self.id = id
    self.context = context
    let backingModel = try await Self.backingModel(identifiedAs: id, insertedInto: context)
    var title = backingModel.title
    normalize(title: &title)
    self.title = title
    var abstract = backingModel.abstract
    normalize(abstract: &abstract)
    self.abstract = abstract
    self.status = backingModel.status
    self.deadline = backingModel.deadline
  }

  public func setStatus(to newStatus: Status) async throws {
    try await backingModel.setValue(forKey: \.status, to: newStatus)
    try await context.save()
  }

  public func setDeadline(to newDeadline: Date) async throws {
    try await backingModel.setValue(forKey: \.deadline, to: newDeadline)
    try await context.save()
  }
}

extension PersistedToDo: Hashable {
  public func hash(into hasher: inout Hasher) {
    id.hash(into: &hasher)
    title.hash(into: &hasher)
    abstract.hash(into: &hasher)
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
  private(set) fileprivate var abstract: String
  private(set) fileprivate var status: Status
  private(set) fileprivate var deadline: Date

  public static var titleKeyPath: KeyPath<ToDoModel, String> { \.title }
  public static var abstractKeyPath: KeyPath<ToDoModel, String> { \.abstract }

  fileprivate convenience init(describedBy descriptor: AnyToDoDescriptor, goalUUID: UUID) {
    self.init(
      uuid: .init(),
      goalUUID: goalUUID,
      title: descriptor.title,
      abstract: descriptor.abstract,
      status: descriptor.status,
      deadline: descriptor.deadline
    )
  }

  required init(
    uuid: UUID,
    goalUUID: UUID,
    title: String,
    abstract: String,
    status: Status,
    deadline: Date
  ) {
    self.uuid = uuid
    self.goalUUID = goalUUID
    self.title = title
    self.abstract = abstract
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
      abstract: abstract,
      status: status,
      deadline: deadline
    )
  }
}

/// Protocol common to ``CorePlanner``-related types supporting persistence backed by the SwiftData
/// framework.
///
/// Conforming to this protocol includes support for normalization of the headline of the model
/// (upon both initialization and changes through the setters) and domain-driven behavior, e.g.,
/// adding to-dos to goals and goals to plans, without exposing details about the underlying
/// persistence layer.
public protocol PersistedDomain: ~Copyable, Hashable, Sendable, SendableMetatype {
  /// The persisted model on which this structure is based.
  associatedtype BackingModel: PartialHeadlined & PersistentModel & NSCopying

  /// Context of the model backing this implementation.
  var context: PersistenceContext { get }

  var id: UUID { get }

  /// Makes an instance of this type from the ID of the model persisted into the container, backing
  /// accesses to each of its properties, adding normalization to the headline of such model and
  /// overall domain-driven behavior (e.g., adding to-dos to goals and goals to plans).
  ///
  /// - Parameters:
  ///   - id: The stable identity of the entity associated with this instance.
  ///   - context: Context into which the model is inserted.
  init(
    identifiedAs id: UUID,
    insertedInto context: PersistenceContext
  ) async throws
}

extension PersistedDomain {
  /// Copy of the object persisted into the container and on which the headline of this
  /// implementation is based.
  ///
  /// - SeeAlso: ``backingModel(identifiedAs:insertedInto:)``
  fileprivate var backingModel: BackingModel {
    get async throws {
      try await Self.backingModel(identifiedAs: id, insertedInto: context)
    }
  }

  /// Retrieves a copy of the object persisted into the container and on which the headline of this
  /// implementation is based.
  ///
  /// ###### Implementation notes
  ///
  /// The backing model is retrieved from the ``context`` by copy through a snapshot. This is far
  /// from ideal, given that copying is not synchronized and may be made outdated due to changes by
  /// another caller.
  ///
  /// In a greater, more complex program, this could be an issue, and this function would (maybe)
  /// have to be declared with a sendable closure to which the backing model is provided; in our
  /// situation, however, this detail will probably do no harm.
  ///
  /// - Parameters:
  ///   - uuid: The ID of the backing model.
  ///   - context: Context into which the backing model is inserted.
  /// - SeeAlso: ``backingModel``
  fileprivate static func backingModel(
    identifiedAs id: UUID,
    insertedInto context: PersistenceContext
  ) async throws -> BackingModel {
    let snapshot = try await context.run { context in
      guard
        let backingModel = try context.fetch(
          .one,
          where: #Predicate<BackingModel> { backingModel in backingModel.uuid == id }
        )
      else {
        throw PlannerError<SwiftDataError>.nonexistent(type: Self.self, id: id)
      }
      return Snapshot(of: backingModel)
    }
    return snapshot.copy()
  }

  public func setTitle(to newTitle: String) async throws {
    var newTitle = newTitle
    normalize(title: &newTitle)
    try await backingModel.setValue(forKey: BackingModel.titleKeyPath, to: newTitle)
    try await context.save()
  }

  public func setAbstract(to newAbstract: String) async throws {
    var newAbstract = newAbstract
    normalize(abstract: &newAbstract)
    try await backingModel.setValue(forKey: BackingModel.abstractKeyPath, to: newAbstract)
    try await context.save()
  }
}

extension PersistedDomain where Self: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
}

/// Protocol to which each model of a ``CorePlanner`` structure conforms, indicating that such model
/// is titled and summarized. The partiality is due to neither its title nor its abstract having been
/// normalized, which denotes that they may be deemed invalid by an actual `Headlined`.
public protocol PartialHeadlined {
  /// The stable identifier of this structure, safely-usable accross model contexts.
  ///
  /// This likely goes against
  /// [*The Laws of Core Data*](https://davedelong.com/blog/2018/05/09/the-laws-of-core-data)
  /// formulated by Dave DeLong, but acts as a workaround for some fetching problems the author of
  /// Pragma was having (due to a skill issue).
  var uuid: UUID { get }

  /// Key path of the title.
  static var titleKeyPath: KeyPath<Self, String> { get }

  /// Key path of the description.
  static var abstractKeyPath: KeyPath<Self, String> { get }
}
