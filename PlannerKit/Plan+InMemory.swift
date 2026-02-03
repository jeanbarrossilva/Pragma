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

extension Planner where Self == InMemoryPlanner {
  /// Alias for the initialization of an ``InMemoryPlanner``.
  public static func inMemory() -> InMemoryPlanner { InMemoryPlanner() }
}

/// Planner which stores its plans, goals and to-dos in memory. Persistence is, therefore, not
/// supported: all data added to it will be removed upon its deinitialization, and will not be
/// recoverable afterward; every newly initialized instance of this planner is in an untouched
/// state.
public struct InMemoryPlanner: ~Copyable, Planner {
  public typealias ImplementationError = NSError

  /// Plans added to this planner.
  private var plans = OwnedArray<InMemoryPlan>()

  public mutating func addPlan(
    describedBy descriptor: AnyPlanDescriptor
  ) async throws -> UUID {
    let plan = InMemoryPlan(describedBy: descriptor)
    let id = plan.id
    plans.append(plan)
    return id
  }

  public func withPlans<Result>(
    _ action: (borrowing OwnedArray<InMemoryPlan>) async throws -> Result
  ) async throws -> Result where Result: Sendable {
    try await action(plans)
  }

  public func withPlan<Result>(
    identifiedAs id: UUID,
    _ action: (borrowing InMemoryPlan) async throws -> Result
  ) async throws -> Result where Result: Sendable {
    guard let result = try await plans.withFirst(where: { plan in plan.id == id }, action) else {
      throw PlannerError<NSError>.nonexistent(type: PlanType.self, id: id)
    }
    return result
  }

  public mutating func removePlan(identifiedAs id: UUID) async throws {
    guard let index = plans.firstIndex(where: { plan in plan.id == id }) else { return }
    plans.remove(at: index)
  }

  public consuming func clear() async throws { plans.removeAll() }
}

/// Plan whose modifications, including those on its goals and to-dos, are performed in-memory,
/// maintained only for as long as the program is being executed, with changes on these structs
/// being discarded upon their deinitialization.
public struct InMemoryPlan: ~Copyable, Plan {
  public typealias ImplementationError = NSError

  public let id = UUID()
  public private(set) var title: String
  public private(set) var abstract: String

  /// Goals added to this plan.
  private var goals = OwnedArray<InMemoryGoal>()

  /// Initializes this type of ``Plan`` from a descriptor.
  ///
  /// - Parameter descriptor: Immutable instance responsible for describing the user-defined values
  ///   of properties of this ``Plan``.
  fileprivate init(describedBy descriptor: AnyPlanDescriptor) {
    var title = descriptor.title
    normalize(title: &title)
    self.title = title
    var abstract = descriptor.abstract
    normalize(abstract: &abstract)
    self.abstract = abstract
    self.goals = .init()
  }

  public mutating func setTitle(to newTitle: String) async throws {
    var newTitle = newTitle
    normalize(title: &newTitle)
    title = newTitle
  }

  public mutating func setAbstract(to newAbstract: String) async throws {
    var newAbstract = newAbstract
    normalize(abstract: &newAbstract)
    abstract = newAbstract
  }

  public mutating func addGoal(
    describedBy descriptor: AnyGoalDescriptor
  ) async throws -> UUID {
    let goal = InMemoryGoal(describedBy: descriptor)
    let goalID = goal.id
    goals.append(goal)
    return goalID
  }

  public func withGoals<Result>(
    _ action: (borrowing OwnedArray<InMemoryGoal>) async throws -> Result
  ) async throws -> Result where Result: Sendable {
    try await action(goals)
  }

  public func withGoal<Result>(
    identifiedAs id: ID,
    _ action: (borrowing InMemoryGoal) async throws -> Result
  ) async throws -> Result where Result: Sendable {
    guard let result = try await goals.withFirst(where: { goal in goal.id == id }, action) else {
      throw PlannerError<NSError>.nonexistent(type: GoalType.self, id: id)
    }
    return result
  }

  public mutating func removeGoal(identifiedAs id: UUID) async throws {
    guard let index = goals.firstIndex(where: { goal in goal.id == id }) else { return }
    goals.remove(at: index)
  }
}

/// Goal whose modifications and those on its to-dos are performed in-memory, maintained only for as
/// long as the program is being executed, with changes on these structs being discarded upon their
/// deinitialization.
public struct InMemoryGoal: ~Copyable, Goal {
  public typealias ToDoDescriptor = AnyToDoDescriptor
  public typealias ImplementationError = NSError

  public let id = UUID()
  public private(set) var title: String
  public private(set) var abstract: String

  /// To-dos added to this goal.
  private var toDos = OwnedArray<InMemoryToDo>()

  /// Initializes an ``InMemoryGoal`` from a descriptor.
  ///
  /// - Parameter descriptor: Immutable instance responsible for describing the user-defined values
  ///   of properties of this ``Goal``.
  fileprivate init(describedBy descriptor: AnyGoalDescriptor) {
    var title = descriptor.title
    normalize(title: &title)
    self.title = title
    var abstract = descriptor.abstract
    normalize(abstract: &abstract)
    self.abstract = abstract
    for toDoDescriptor in descriptor.toDos { toDos.append(.init(describedBy: toDoDescriptor)) }
  }

  public mutating func setTitle(to newTitle: String) async throws {
    var newTitle = newTitle
    normalize(title: &newTitle)
    title = newTitle
  }

  public mutating func setAbstract(to newAbstract: String) async throws {
    var newAbstract = newAbstract
    normalize(abstract: &newAbstract)
    abstract = newAbstract
  }

  public mutating func addToDo(
    describedBy descriptor: AnyToDoDescriptor
  ) async throws -> UUID {
    let toDo = InMemoryToDo(describedBy: descriptor)
    let toDoID = toDo.id
    toDos.append(toDo)
    return toDoID
  }

  public func withToDos<Result>(
    _ action: (borrowing OwnedArray<InMemoryToDo>) async throws -> Result
  ) async throws -> Result where Result: Sendable {
    try await action(toDos)
  }

  public func withToDo<Result>(
    identifiedAs id: UUID,
    _ action: (borrowing InMemoryToDo) async throws -> Result
  ) async throws -> Result where Result: Sendable {
    guard let result = try await toDos.withFirst(where: { toDo in toDo.id == id }, action) else {
      throw PlannerError<NSError>.nonexistent(type: InMemoryToDo.self, id: id)
    }
    return result
  }

  public mutating func removeToDo(identifiedAs id: UUID) async throws {
    guard let index = toDos.firstIndex(where: { toDo in toDo.id == id }) else { return }
    _ = toDos.remove(at: index)
  }
}

/// To-do of a ``DemoGoal`` whose modifications are performed in-memory, maintained for as long as
/// the program is being executed and discarted upon the deinitialization of this struct.
public struct InMemoryToDo: ~Copyable, ToDo {
  public typealias ImplementationError = NSError

  public let id = UUID()
  public private(set) var title: String
  public private(set) var abstract: String
  public private(set) var status: Status
  public private(set) var deadline: Date

  /// Initializes this type of ``ToDo`` from a ``Descriptor``.
  ///
  /// - Parameter descriptor: Immutable instance responsible for describing the user-defined values
  ///   of properties of this ``ToDo``.
  fileprivate init(describedBy descriptor: AnyToDoDescriptor) {
    var title = descriptor.title
    normalize(title: &title)
    self.title = title
    var abstract = descriptor.abstract
    normalize(abstract: &abstract)
    self.abstract = abstract
    self.status = descriptor.status
    self.deadline = descriptor.deadline
  }

  public mutating func setTitle(to newTitle: String) async throws {
    var newTitle = newTitle
    normalize(title: &newTitle)
    title = newTitle
  }

  public mutating func setAbstract(to newAbstract: String) async throws {
    var newAbstract = newAbstract
    normalize(abstract: &newAbstract)
    abstract = newAbstract
  }

  public mutating func setStatus(to newStatus: Status) async throws {
    status = newStatus
  }

  public mutating func setDeadline(to newDeadline: Date) async throws {
    deadline = newDeadline
  }
}
