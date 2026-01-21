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

extension Planning {
  /// Alias for the initialization of a ``PlanRepository``.
  public static func makeRepository() throws -> PlannerRepository {
    try makeRepository(isInMemory: false)
  }

  /// Produces an instance of a ``PlannerRepository``.
  ///
  /// - Parameter isInMemory: Whether plans, goals and to-dos are stored in memory, as opposed to
  ///   persisted in disk.
  static func makeRepository(isInMemory: Bool) throws -> PlannerRepository {
    try PlannerRepository(
      modelContainer: .init(
        for: .init(PlannerRepository.modelTypes),
        configurations: .init(isStoredInMemoryOnly: isInMemory)
      )
    )
  }
}

/// Abstraction for accessing a container in which ``CorePlanner`` structures are inserted, with
/// the stored data being retrievable after deinitialization of this class or the underlying
/// implementations of ``CorePlanner/Plan``, ``CorePlanner/Goal`` and ``CorePlanner/ToDo``.
@ModelActor
public actor PlannerRepository {
  /// Types of models insertable into this repository.
  ///
  /// ###### Implmentation notes
  ///
  /// `PersistedPlan` is the only type of model included in this array because SwiftData infers
  /// others (`PersitedGoal`, `PersistedToDos`, …) based on the relationships of models whose types
  /// is the ones given to the framework (Stanford University, 2025,
  /// [*L13: SwiftData*](https://youtu.be/k9wjAdgUY0A?t=794)).
  public static let modelTypes: [any PersistentModel.Type] = [PlanModel.self]

  /// Inserts a plan without goals into the underlying container.
  ///
  /// - Parameters:
  ///   - title: ``CorePlanner/Headlineable/title`` of the plan.
  ///   - summary: ``CorePlanner/Headlineable/summary`` of the plan.
  /// - Returns: The ID of the added plan.
  public func insertPlan(
    titled title: String,
    summarizedBy summary: String
  ) async throws(PersistenceError) -> some Plan {
    let model = PlanModel(title: title, summary: summary)
    modelContext.insert(model)
    return try PersistedPlan(identifiedAs: model.id, insertedInto: modelContext)
  }

  /// Retrieves an inserted plan identified with the given ID.
  ///
  /// - Parameter id: ID of the plan to be retrieved.
  /// - Returns: The plan, or `nil` in case no plan with the ID is found.
  public func plan(identifiedAs id: Any) async throws(PersistenceError) -> (some Plan)? {
    guard
      let id = id as? PersistentIdentifier,
      let model: PlanModel = modelContext.registeredModel(for: id)
    else { return nil as PersistedPlan? }
    return try PersistedPlan(from: model)
  }

  /// Performs the given closure on this ``PlannerRepository``.
  ///
  /// - Parameter action: Operation to be performed.
  public func run(
    _ action: @Sendable (isolated PlannerRepository) async throws -> Void
  ) async rethrows {
    try await action(self)
  }
}

/// Failure happened upon reading the value of a property of a model or a saving changes
/// (insertions, updates or deletions) to a persistence container.
public enum PersistenceError: Error {
  /// The context of a persisted model is unavailable (i.e., given a model `model`,
  /// `model.modelContext` = `nil`), preventing the model from being retrieved or deleted from the
  /// container; or having its attributes updated.
  ///
  /// - Parameter type: Type of the model without a context.
  case modelWithoutContext(type: any PersistentModel.Type)

  /// A model required to have been inserted and identified with the provided identifier is not in
  /// the container. This error should not occur, as it denotes a bug in the persistence logic
  /// itself.
  ///
  /// - Parameters:
  ///   - type: Type of the missing model.
  ///   - id: ID of the model which should have been persisted in the container.
  case modelNotFound(type: any PersistentModel.Type, id: PersistentIdentifier)
}

/// Plan persisted into a container by a ``PlannerRepository``.
private struct PersistedPlan: PersistedDomain, Plan {
  typealias BackingModel = PlanModel

  let context: ModelContext
  let id: PersistentIdentifier
  let title: String
  let summary: String

  var goals: [PersistedGoal] {
    (try? context
      .fetch(
        .init(
          predicate: #Predicate { (goalModel: GoalModel) in goalModel.planID == id },
          sortBy: [.init(\.title), .init(\.summary)]
        )
      )
      .map { goalModel in try .init(from: goalModel) })
      ?? []
  }

  static let description = "plan"

  init(
    identifiedAs id: PersistentIdentifier,
    insertedInto context: ModelContext
  ) throws(PersistenceError) {
    let backingModel = try Self.backingModel(identifiedAs: id, insertedInto: context)
    self.context = context
    self.id = backingModel.id
    var title = backingModel.title
    Self.normalize(title: &title)
    self.title = title
    var summary = backingModel.summary
    Self.normalize(summary: &summary)
    self.summary = summary
  }

  func addGoal(
    titled title: String,
    summarizedBy summary: String
  ) async throws(PersistenceError) -> PersistedGoal {
    let goalModel = GoalModel(planID: id, title: title, summary: summary)
    let goal = try PersistedGoal(from: goalModel)
    context.insert(goalModel)
    return goal
  }

  func removeGoal(identifiedAs id: PersistentIdentifier) async throws {
    try context.delete(
      model: GoalModel.self,
      where: #Predicate { goalModel in goalModel.id == id },
      includeSubclasses: false
    )
  }
}

extension PersistedPlan: Hashable {
  func hash(into hasher: inout Hasher) {
    id.hash(into: &hasher)
    title.hash(into: &hasher)
    summary.hash(into: &hasher)
    goals.hash(into: &hasher)
  }
}

/// Goal persisted into a container by its ``PersistedPlan``.
private struct PersistedGoal: PersistedDomain, Goal {
  typealias BackingModel = GoalModel

  let context: ModelContext
  let id: PersistentIdentifier
  let title: String
  let summary: String

  var toDos: [PersistedToDo] {
    (try? context
      .fetch(
        .init(
          predicate: #Predicate { (toDoModel: ToDoModel) in toDoModel.goalID == id },
          sortBy: [.init(\.deadline), .init(\.title), .init(\.summary)]
        )
      )
      .map { toDoModel in try .init(from: toDoModel) })
      ?? []
  }

  static let description = "goal"

  init(
    identifiedAs id: PersistentIdentifier,
    insertedInto context: ModelContext
  ) throws(PersistenceError) {
    let backingModel = try Self.backingModel(identifiedAs: id, insertedInto: context)
    self.context = context
    self.id = backingModel.id
    var title = backingModel.title
    Self.normalize(title: &title)
    self.title = title
    var summary = backingModel.summary
    Self.normalize(summary: &summary)
    self.summary = summary
  }

  func addToDo(
    titled title: String,
    summarizedBy summary: String,
    due deadline: Date
  ) async throws(PersistenceError) -> PersistedToDo {
    let toDoModel = ToDoModel(goalID: id, title: title, summary: summary, deadline: deadline)
    let toDo = try PersistedToDo(from: toDoModel)
    context.insert(toDoModel)
    return toDo
  }

  func removeToDo(identifiedAs id: PersistentIdentifier) async throws {
    try context.delete(
      model: ToDoModel.self,
      where: #Predicate { toDoModel in toDoModel.id == id },
      includeSubclasses: false
    )
  }
}

extension PersistedGoal: Hashable {
  func hash(into hasher: inout Hasher) {
    id.hash(into: &hasher)
    title.hash(into: &hasher)
    summary.hash(into: &hasher)
    toDos.hash(into: &hasher)
  }
}

/// To-do persisted into a container by its ``PersistedGoal``.
private struct PersistedToDo: PersistedDomain, ToDo {
  typealias BackingModel = ToDoModel

  let context: ModelContext
  let id: PersistentIdentifier
  let title: String
  let summary: String
  let status: Status
  let deadline: Date

  static let description = "to-do"

  init(
    identifiedAs id: PersistentIdentifier,
    insertedInto context: ModelContext
  ) throws(PersistenceError) {
    let backingModel = try Self.backingModel(identifiedAs: id, insertedInto: context)
    self.context = context
    self.id = backingModel.id
    var title = backingModel.title
    Self.normalize(title: &title)
    self.title = title
    var summary = backingModel.summary
    Self.normalize(summary: &summary)
    self.summary = summary
    self.status = backingModel.status
    self.deadline = backingModel.deadline
  }

  func setStatus(to newStatus: Status) async throws(PersistenceError) {
    try backingModel.setValue(forKey: \.status, to: newStatus)
  }

  func setDeadline(to newDeadline: Date) async throws(PersistenceError) {
    try backingModel.setValue(forKey: \.deadline, to: newDeadline)
  }
}

extension PersistedToDo: Hashable {
  func hash(into hasher: inout Hasher) {
    id.hash(into: &hasher)
    title.hash(into: &hasher)
    summary.hash(into: &hasher)
    status.hash(into: &hasher)
    deadline.hash(into: &hasher)
  }
}

/// Protocol common to ``CorePlanner``-related types supporting persistence backed by the SwiftData
/// framework.
///
/// Conforming to this protocol includes support for normalization of the headline of the model
/// (upon both initialization and changes through the setters) and domain-driven behavior, e.g.,
/// adding to-dos to goals and goals to plans, without exposing details about the underlying
/// persistence layer.
private protocol PersistedDomain: Headlineable where ID == PersistentIdentifier {
  /// The persisted model on which this structure is based.
  associatedtype BackingModel: PartialHeadlined & PersistentModel

  /// Context of the model backing this implementation.
  var context: ModelContext { get }

  var title: String { get }
  var summary: String { get }

  /// Makes an instance of this type from the ID of the model persisted into the container, backing
  /// accesses to each of its properties, adding normalization to the headline of such model and
  /// overall domain-driven behavior (e.g., adding to-dos to goals and goals to plans).
  init(
    identifiedAs id: PersistentIdentifier,
    insertedInto context: ModelContext
  ) throws(PersistenceError)
}

extension PersistedDomain {
  /// Object persisted into the container and on which the headline of this implementation is based.
  var backingModel: BackingModel {
    get throws(PersistenceError) { try Self.backingModel(identifiedAs: id, insertedInto: context) }
  }

  /// Makes an instance of this type from the model persisted into the container, backing accesses
  /// to each of its properties, adding normalization to the headline of such model and overall
  /// domain-driven behavior (e.g., adding to-dos to goals and goals to plans).
  init(from model: BackingModel) throws(PersistenceError) {
    guard let context = model.modelContext
    else { throw .modelWithoutContext(type: BackingModel.self) }
    self = try .init(identifiedAs: model.id, insertedInto: context)
  }

  /// Retrieves the object persisted into the container and on which the headline of this
  /// implementation is based.
  static func backingModel(
    identifiedAs id: PersistentIdentifier,
    insertedInto context: ModelContext
  ) throws(PersistenceError) -> BackingModel {
    guard let model = context.registeredModel(for: id) as BackingModel? else {
      throw .modelNotFound(type: BackingModel.self, id: id)
    }
    return model
  }
}

extension PersistedDomain where Self: Headlineable {
  mutating func setTitle(to newTitle: String) async throws(PersistenceError) {
    var newTitle = newTitle
    Self.normalize(title: &newTitle)
    try backingModel.setValue(forKey: BackingModel.titleKeyPath, to: newTitle)
  }

  mutating func setSummary(to newSummary: String) async throws(PersistenceError) {
    var newSummary = newSummary
    Self.normalize(summary: &newSummary)
    try backingModel.setValue(forKey: BackingModel.summaryKeyPath, to: newSummary)
  }
}

/// Model of a plan persisted into a container by a ``PlannerRepository``.
@Model
private final class PlanModel: PartialHeadlined {
  var title: String
  var summary: String

  static var titleKeyPath: KeyPath<PlanModel, String> { \.title }
  static var summaryKeyPath: KeyPath<PlanModel, String> { \.summary }

  init(title: String, summary: String) {
    self.title = title
    self.summary = summary
  }
}

extension PlanModel: NSCopying {
  func copy(with zone: NSZone? = nil) -> Any { Self.init(title: title, summary: summary) }
}

/// Model of a goal persisted into a container by its ``PersistedPlan``.
@Model
private final class GoalModel: PartialHeadlined {
  var planID: PersistentIdentifier
  var title: String
  var summary: String

  static var titleKeyPath: KeyPath<GoalModel, String> { \.title }
  static var summaryKeyPath: KeyPath<GoalModel, String> { \.summary }

  init(planID: PersistentIdentifier, title: String, summary: String) {
    self.planID = planID
    self.title = title
    self.summary = summary
  }
}

/// Model of a to-do persisted into a container by its ``PersistedGoal``.
@Model
private final class ToDoModel: PartialHeadlined {
  var goalID: PersistentIdentifier
  var title: String
  var summary: String
  var status: Status
  var deadline: Date

  static var titleKeyPath: KeyPath<ToDoModel, String> { \.title }
  static var summaryKeyPath: KeyPath<ToDoModel, String> { \.summary }

  init(goalID: PersistentIdentifier, title: String, summary: String, deadline: Date) {
    self.goalID = goalID
    self.title = title
    self.summary = summary
    self.status = .idle
    self.deadline = deadline
  }
}

/// Protocol to which each model of a ``CorePlanner`` structure conforms, indicating that such model
/// is titled and summarized. The partiality is due to neither its title nor its summary having been
/// normalized, which denotes that they may be deemed invalid by an actual `Headlined`.
private protocol PartialHeadlined {
  /// Key path of the title.
  static var titleKeyPath: KeyPath<Self, String> { get }

  /// Key path of the description.
  static var summaryKeyPath: KeyPath<Self, String> { get }
}
