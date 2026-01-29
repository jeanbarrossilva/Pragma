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
    get throws { try persistent(isInMemory: false) }
  }

  /// Produces an instance of a ``PersistentPlanner``.
  ///
  /// - Parameter isInMemory: Whether plans, goals and to-dos are stored in memory, as opposed to
  ///   persisted.
  static func persistent(isInMemory: Bool) throws -> Self {
    try PersistentPlanner(
      modelContainer: .init(
        for: .init(PersistentPlanner.modelTypes),
        configurations: .init(isStoredInMemoryOnly: isInMemory)
      )
    )
  }
}

/// Abstraction for accessing a container in which ``CorePlanner`` structures are inserted, with
/// the stored data being retrievable after deinitialization of this class or the underlying
/// implementations of ``CorePlanner/Plan``, ``CorePlanner/Goal`` and ``CorePlanner/ToDo``.
@ModelActor
public actor PersistentPlanner: Planner {
  public var plans: [PersistedPlan] {
    get throws(PlannerError<PersistenceError>) {
      do {
        return try modelContext.fetch(.init(predicate: Predicate<PlanModel>.true)).map { model in
          try .init(identifiedAs: model.uuid, insertedInto: modelContext)
        }
      } catch {
        throw .implementationSpecific(
          cause: .malformedPredicate(modelType: PlanModel.self)
        )
      }
    }
  }

  /// Types of models insertable into this repository.
  ///
  /// ###### Implmentation notes
  ///
  /// ``PlanModel`` is the only type of model included in this array because SwiftData infers others
  /// (``GoalModel``, ``ToDoModel``, …) based on the relationships of models whose types is the ones
  /// given to the framework (Stanford University, 2025,
  /// [*L13: SwiftData*](https://youtu.be/k9wjAdgUY0A?t=794)).
  public static let modelTypes: [any PersistentModel.Type] = [PlanModel.self]

  public func addPlan(
    describedBy descriptor: AnyPlanDescriptor
  ) throws(PlannerError<PersistenceError>) -> UUID {
    let model = PlanModel(describedBy: descriptor)
    let planUUID = model.uuid
    if descriptor.goals.isEmpty {
      modelContext.insert(model)
      try modelContext._save()
    } else {
      try modelContext._transaction {
        for goalDescriptor in descriptor.goals {
          let goalModel = GoalModel(describedBy: goalDescriptor, planUUID: planUUID)
          modelContext.insert(goalModel)
          for toDoDescriptor in goalDescriptor.toDos {
            modelContext.insert(ToDoModel(describedBy: toDoDescriptor, goalUUID: goalModel.uuid))
          }
        }
      }
    }
    return model.uuid
  }

  public func plan(identifiedAs id: UUID) throws(PlannerError<PersistenceError>) -> PersistedPlan {
    try .init(identifiedAs: id, insertedInto: modelContext)
  }

  public func removePlan(identifiedAs id: UUID) throws(PlannerError<PersistenceError>) {
    do {
      try modelContext.delete(
        model: PlanModel.self,
        where: #Predicate { model in model.uuid == id }
      )
      try modelContext._save()
    } catch {
      throw .implementationSpecific(cause: .malformedPredicate(modelType: PlanModel.self))
    }
  }

  public func clear() throws(PlannerError<PersistenceError>) {
    modelContainer.deleteAllData()
  }
}

/// Plan persisted into a container by a ``PersistentPlanner``.
public final class PersistedPlan: PersistedDomain, Plan {
  public typealias Descriptor = AnyPlanDescriptor
  public typealias BackingModel = PlanModel

  public let context: ModelContext
  public let id: UUID
  public let title: String
  public let summary: String

  public var goals: [PersistedGoal] {
    get throws(PlannerError<PersistenceError>) {
      let fetchDescriptor = FetchDescriptor(
        predicate: #Predicate<GoalModel> { goalModel in goalModel.planUUID == id },
        sortBy: [.init(\.title), .init(\.summary)]
      )
      do {
        return try context.fetch(fetchDescriptor).map { goalModel in
          try .init(identifiedAs: goalModel.uuid, insertedInto: context)
        }
      } catch {
        throw .implementationSpecific(cause: .malformedPredicate(modelType: GoalModel.self))
      }
    }
  }

  public init(
    identifiedAs id: UUID,
    insertedInto context: ModelContext
  ) throws(PlannerError<PersistenceError>) {
    self.id = id
    self.context = context
    let backingModel = try Self.backingModel(identifiedAs: id, insertedInto: context)
    var title = backingModel.title
    Self.normalize(title: &title)
    self.title = title
    var summary = backingModel.summary
    Self.normalize(summary: &summary)
    self.summary = summary
  }

  public func addGoal(
    describedBy descriptor: AnyGoalDescriptor
  ) async throws(PlannerError<PersistenceError>) -> UUID {
    let goalModel = GoalModel(describedBy: descriptor, planUUID: id)
    let goalUUID = goalModel.uuid
    if descriptor.toDos.isEmpty {
      context.insert(goalModel)
      try context._save()
    } else {
      try context._transaction {
        for toDoDescriptor in descriptor.toDos {
          let toDoModel = ToDoModel(describedBy: toDoDescriptor, goalUUID: goalUUID)
          context.insert(toDoModel)
        }
      }
    }
    return goalModel.uuid
  }

  public func goal(
    identifiedAs id: UUID
  ) async throws(PlannerError<PersistenceError>) -> PersistedGoal {
    try .init(identifiedAs: id, insertedInto: context)
  }

  public func removeGoal(identifiedAs id: UUID) async throws(PlannerError<PersistenceError>) {
    do {
      try context.delete(
        model: GoalModel.self,
        where: #Predicate { goalModel in goalModel.uuid == id },
        includeSubclasses: false
      )
      try context._save()
    } catch {
      throw .implementationSpecific(cause: .malformedPredicate(modelType: GoalModel.self))
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

/// Model of a plan persisted into a container by a ``PersistentPlanner``.
@Model
public final class PlanModel: PartialHeadlined {
  private(set) public var uuid = UUID()

  private(set) fileprivate var title: String
  fileprivate var summary: String

  public static var titleKeyPath: KeyPath<PlanModel, String> { \.title }
  public static var summaryKeyPath: KeyPath<PlanModel, String> { \.summary }

  init(describedBy descriptor: AnyPlanDescriptor) {
    self.title = descriptor.title
    self.summary = descriptor.summary
  }
}

/// Goal persisted into a container by its ``PersistedPlan``.
public final class PersistedGoal: PersistedDomain, Goal {
  public typealias Descriptor = AnyGoalDescriptor
  public typealias BackingModel = GoalModel

  public let context: ModelContext
  public let id: UUID
  public let title: String
  public let summary: String

  public var toDos: [PersistedToDo] {
    get throws(PlannerError<PersistenceError>) {
      let fetchDescriptor = FetchDescriptor(
        predicate: #Predicate<ToDoModel> { toDoModel in toDoModel.goalUUID == id },
        sortBy: [.init(\.deadline), .init(\.title), .init(\.summary)]
      )
      do {
        return try context.fetch(fetchDescriptor).map { toDoModel in
          try .init(identifiedAs: toDoModel.uuid, insertedInto: context)
        }
      } catch {
        throw .implementationSpecific(cause: .malformedPredicate(modelType: ToDoModel.self))
      }
    }
  }

  public init(
    identifiedAs id: UUID,
    insertedInto context: ModelContext
  ) throws(PlannerError<PersistenceError>) {
    self.id = id
    self.context = context
    let backingModel = try Self.backingModel(identifiedAs: id, insertedInto: context)
    var title = backingModel.title
    Self.normalize(title: &title)
    self.title = title
    var summary = backingModel.summary
    Self.normalize(summary: &summary)
    self.summary = summary
  }

  public func addToDo(
    describedBy descriptor: AnyToDoDescriptor
  ) async throws(PlannerError<PersistenceError>) -> UUID {
    let toDoModel = ToDoModel(describedBy: descriptor, goalUUID: id)
    context.insert(toDoModel)
    try context._save()
    return toDoModel.uuid
  }

  public func toDo(
    identifiedAs id: UUID
  ) async throws(PlannerError<PersistenceError>) -> PersistedToDo {
    try .init(identifiedAs: id, insertedInto: context)
  }

  public func removeToDo(identifiedAs id: UUID) async throws(PlannerError<PersistenceError>) {
    do {
      try context.delete(
        model: ToDoModel.self,
        where: #Predicate { toDoModel in toDoModel.uuid == id },
        includeSubclasses: false
      )
      try context._save()
    } catch {
      throw .implementationSpecific(cause: .malformedPredicate(modelType: ToDoModel.self))
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
  private(set) public var uuid = UUID()

  private(set) fileprivate var planUUID: UUID
  private(set) fileprivate var title: String
  private(set) fileprivate var summary: String

  public static var titleKeyPath: KeyPath<GoalModel, String> { \.title }
  public static var summaryKeyPath: KeyPath<GoalModel, String> { \.summary }

  fileprivate init(describedBy descriptor: AnyGoalDescriptor, planUUID: UUID) {
    self.planUUID = planUUID
    self.title = descriptor.title
    self.summary = descriptor.summary
  }
}

/// To-do persisted into a container by its ``PersistedGoal``.
public final class PersistedToDo: PersistedDomain, ToDo {
  public typealias Descriptor = AnyToDoDescriptor
  public typealias BackingModel = ToDoModel

  public let context: ModelContext
  public let id: UUID
  public let title: String
  public let summary: String
  public let status: Status
  public let deadline: Date

  public init(
    identifiedAs id: UUID,
    insertedInto context: ModelContext
  ) throws(PlannerError<PersistenceError>) {
    self.id = id
    self.context = context
    let backingModel = try Self.backingModel(identifiedAs: id, insertedInto: context)
    var title = backingModel.title
    Self.normalize(title: &title)
    self.title = title
    var summary = backingModel.summary
    Self.normalize(summary: &summary)
    self.summary = summary
    self.status = backingModel.status
    self.deadline = backingModel.deadline
  }

  public func setStatus(to newStatus: Status) async throws(PlannerError<PersistenceError>) {
    try backingModel.setValue(forKey: \.status, to: newStatus)
  }

  public func setDeadline(to newDeadline: Date) async throws(PlannerError<PersistenceError>) {
    try backingModel.setValue(forKey: \.deadline, to: newDeadline)
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
  private(set) public var uuid = UUID()

  private(set) fileprivate var goalUUID: UUID
  private(set) fileprivate var title: String
  private(set) fileprivate var summary: String
  private(set) fileprivate var status: Status
  private(set) fileprivate var deadline: Date

  public static var titleKeyPath: KeyPath<ToDoModel, String> { \.title }
  public static var summaryKeyPath: KeyPath<ToDoModel, String> { \.summary }

  fileprivate init(describedBy descriptor: AnyToDoDescriptor, goalUUID: UUID) {
    self.goalUUID = goalUUID
    self.title = descriptor.title
    self.summary = descriptor.summary
    self.status = descriptor.status
    self.deadline = descriptor.deadline
  }
}

/// Protocol common to ``CorePlanner``-related types supporting persistence backed by the SwiftData
/// framework.
///
/// Conforming to this protocol includes support for normalization of the headline of the model
/// (upon both initialization and changes through the setters) and domain-driven behavior, e.g.,
/// adding to-dos to goals and goals to plans, without exposing details about the underlying
/// persistence layer.
public protocol PersistedDomain: Headlineable
where ID == UUID, ImplementationError == PersistenceError {
  /// The persisted model on which this structure is based.
  associatedtype BackingModel: PartialHeadlined & PersistentModel

  /// Context of the model backing this implementation.
  var context: ModelContext { get }

  /// Makes an instance of this type from the ID of the model persisted into the container, backing
  /// accesses to each of its properties, adding normalization to the headline of such model and
  /// overall domain-driven behavior (e.g., adding to-dos to goals and goals to plans).
  ///
  /// - Parameters:
  ///   - id: The stable identity of the entity associated with this instance.
  ///   - context: Context into which the model is inserted.
  init(
    identifiedAs id: UUID,
    insertedInto context: ModelContext
  ) throws(PlannerError<PersistenceError>)
}

extension PersistedDomain {
  /// Object persisted into the container and on which the headline of this implementation is based.
  ///
  /// - SeeAlso: ``backingModel(identifiedAs:insertedInto:)``
  fileprivate var backingModel: BackingModel {
    get throws(PlannerError<PersistenceError>) {
      try Self.backingModel(identifiedAs: id, insertedInto: context)
    }
  }

  /// Retrieves the object persisted into the container and on which the headline of this
  /// implementation is based.
  ///
  /// - Parameters:
  ///   - uuid: The ID of the backing model.
  ///   - context: Context into which the backing model is inserted.
  /// - SeeAlso: ``backingModel``
  fileprivate static func backingModel(
    identifiedAs id: UUID,
    insertedInto context: ModelContext
  ) throws(PlannerError<PersistenceError>) -> BackingModel {
    let fetchDescriptor = FetchDescriptor(
      predicate: #Predicate<BackingModel> { backingModel in backingModel.uuid == id }
    )
    guard let backingModels = try? context.fetch(fetchDescriptor) else {
      throw .implementationSpecific(cause: .malformedPredicate(modelType: BackingModel.self))
    }
    guard let backingModel = backingModels.first
    else { throw .nonexistent(type: Self.self, id: id) }
    return backingModel
  }
}

extension PersistedDomain where Self: Headlineable {
  public func setTitle(to newTitle: String) async throws(PlannerError<PersistenceError>) {
    var newTitle = newTitle
    Self.normalize(title: &newTitle)
    try backingModel.setValue(forKey: BackingModel.titleKeyPath, to: newTitle)
  }

  public func setSummary(to newSummary: String) async throws(PlannerError<PersistenceError>) {
    var newSummary = newSummary
    Self.normalize(summary: &newSummary)
    try backingModel.setValue(forKey: BackingModel.summaryKeyPath, to: newSummary)
  }
}

/// Failure happened upon reading the value of a property of a model or a saving changes
/// (insertions, updates or deletions) to a persistence container.
public enum PersistenceError: Error {
  /// A single or batch insertion of, update to or deletion of models from the container has failed.
  /// The documentation of neither
  /// [SwiftData](https://developer.apple.com/documentation/swiftdata/modelcontext/save()) nor
  /// [Core Data](https://developer.apple.com/documentation/coredata/nsmanagedobjectcontext/save())
  /// specify when, exactly, this error occurs; the empirical (and unverified) guess of the author
  /// of Pragma is that it may be thrown due to a migration failure or in case the device runs out
  /// of storage.
  case failedTransaction

  /// A predicate for retrieving or deleting one or more models from the container contains
  /// expressions which cannot be converted into an SQL query by SwiftData.
  case malformedPredicate(modelType: any PersistentModel.Type)
}

extension PersistenceError: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.failedTransaction, .failedTransaction):
      true
    case (.malformedPredicate(let lhsType), .malformedPredicate(let rhsType)):
      lhsType == rhsType
    default:
      false
    }
  }
}

/// Protocol to which each model of a ``CorePlanner`` structure conforms, indicating that such model
/// is titled and summarized. The partiality is due to neither its title nor its summary having been
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
  static var summaryKeyPath: KeyPath<Self, String> { get }
}

extension ModelContext {
  fileprivate func _transaction(action: () -> Void) throws(PlannerError<PersistenceError>) {
    do { try transaction(block: action) } catch {
      throw .implementationSpecific(cause: .failedTransaction)
    }
  }

  fileprivate func _save() throws(PlannerError<PersistenceError>) {
    guard hasChanges else { return }
    do { try save() } catch { throw .implementationSpecific(cause: .failedTransaction) }
  }
}
