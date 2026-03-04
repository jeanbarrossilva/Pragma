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

extension Planner where Self == InMemoryPlanner {
  /// Alias for the initialization of an ``InMemoryPlanner``.
  public static func inMemory() -> InMemoryPlanner { InMemoryPlanner() }
}

/// Planner which stores its plans, goals and to-dos in memory. Persistence is,
/// therefore, not supported: all data added to it will be removed upon its
/// deinitialization, and will not be recoverable afterward; every newly
/// initialized instance of this planner is in an untouched state.
public struct InMemoryPlanner: Planner {
  public typealias ImplementationError = NSError

  private(set) public var plans = [InMemoryPlan]()

  public mutating func addPlan(
    describedBy descriptor: AnyPlanDescriptor
  ) async throws -> UUID {
    let plan = InMemoryPlan(describedBy: descriptor)
    plans.append(plan)
    return plan.id
  }

  public func plan(identifiedAs id: UUID) async throws -> InMemoryPlan {
    guard let plan = plans.first(where: { plan in plan.id == id }) else {
      throw PlannerError.nonexistent(type: InMemoryPlan.self, id: id)
    }
    return plan
  }

  public mutating func removePlan(identifiedAs id: UUID) async throws {
    guard let index = plans.firstIndex(where: { plan in plan.id == id }) else {
      return
    }
    plans.remove(at: index)
  }

  public mutating func clear() async throws { plans.removeAll() }
}

/// Plan whose modifications, including those on its goals and to-dos, are
/// performed in-memory, maintained only for as long as the program is being
/// executed, with changes on these structs being discarded upon their
/// deinitialization.
public struct InMemoryPlan: Plan {
  public typealias Descriptor = AnyPlanDescriptor
  public typealias ImplementationError = NSError

  public let id = UUID()
  public private(set) var title: String
  public private(set) var summary: String
  public private(set) var goals: [InMemoryGoal]

  public static let description = "plan"

  /// Initializes this type of ``Plan`` from a ``Descriptor``.
  ///
  /// - Parameter descriptor: Immutable instance responsible for describing the
  ///   user-defined values of properties of this ``Plan``.
  fileprivate init(describedBy descriptor: AnyPlanDescriptor) {
    var title = descriptor.title
    normalize(title: &title)
    self.title = title
    var summary = descriptor.summary
    normalize(summary: &summary)
    self.summary = summary
    self.goals = descriptor.goals.map { goalDescriptor in
      .init(describedBy: goalDescriptor)
    }
  }

  public mutating func setTitle(to newTitle: String) async throws {
    var newTitle = newTitle
    normalize(title: &newTitle)
    title = newTitle
  }

  public mutating func setSummary(to newSummary: String) async throws {
    var newSummary = newSummary
    normalize(summary: &newSummary)
    summary = newSummary
  }

  public mutating func addGoal(
    describedBy descriptor: AnyGoalDescriptor
  ) async throws -> UUID {
    let goal = InMemoryGoal(describedBy: descriptor)
    goals.append(goal)
    return goal.id
  }

  public func goal(identifiedAs id: UUID) async throws -> InMemoryGoal {
    guard let goal = goals.first(where: { goal in goal.id == id }) else {
      throw PlannerError.nonexistent(type: InMemoryGoal.self, id: id)
    }
    return goal
  }

  public mutating func removeGoal(identifiedAs id: UUID) async throws {
    guard let index = goals.firstIndex(where: { goal in goal.id == id }) else {
      return
    }
    goals.remove(at: index)
  }
}

/// Goal whose modifications and those on its to-dos are performed in-memory,
/// maintained only for as long as the program is being executed, with changes
/// on these structs being discarded upon their deinitialization.
public struct InMemoryGoal: Goal {
  public typealias Descriptor = AnyGoalDescriptor
  public typealias ImplementationError = NSError

  public let id = UUID()
  public private(set) var title: String
  public private(set) var summary: String
  public private(set) var toDos: [InMemoryToDo]

  public static let description = "goal"

  /// Initializes this type of ``Goal`` from a ``Descriptor``.
  ///
  /// - Parameter descriptor: Immutable instance responsible for describing the
  ///   user-defined values of properties of this ``Goal``.
  fileprivate init(describedBy descriptor: AnyGoalDescriptor) {
    var title = descriptor.title
    normalize(title: &title)
    self.title = title
    var summary = descriptor.summary
    normalize(summary: &summary)
    self.summary = summary
    self.toDos = descriptor.toDos.map { toDoDescriptor in
      .init(describedBy: toDoDescriptor)
    }
  }

  public mutating func setTitle(to newTitle: String) async throws {
    var newTitle = newTitle
    normalize(title: &newTitle)
    title = newTitle
  }

  public mutating func setSummary(to newSummary: String) async throws {
    var newSummary = newSummary
    normalize(summary: &newSummary)
    summary = newSummary
  }

  public mutating func addToDo(
    describedBy descriptor: AnyToDoDescriptor
  ) async throws -> UUID {
    let toDo = InMemoryToDo(describedBy: descriptor)
    toDos.append(toDo)
    return toDo.id
  }

  public func toDo(identifiedAs id: UUID) async throws -> InMemoryToDo {
    guard let toDo = toDos.first(where: { toDo in toDo.id == id }) else {
      throw PlannerError.nonexistent(type: InMemoryToDo.self, id: id)
    }
    return toDo
  }

  public mutating func removeToDo(identifiedAs id: UUID) async throws {
    guard let index = toDos.firstIndex(where: { toDo in toDo.id == id }) else {
      return
    }
    toDos.remove(at: index)
  }
}

/// To-do of a ``DemoGoal`` whose modifications are performed in-memory,
/// maintained for as long as the program is being executed and discarted upon
/// the deinitialization of this struct.
public struct InMemoryToDo: ToDo {
  public typealias Descriptor = AnyToDoDescriptor
  public typealias ImplementationError = NSError

  public let id = UUID()
  public private(set) var title: String
  public private(set) var summary: String
  public private(set) var status: Status
  public private(set) var deadline: Date

  public static let description = "to-do"

  /// Initializes this type of ``ToDo`` from a ``Descriptor``.
  ///
  /// - Parameter descriptor: Immutable instance responsible for describing
  ///   the user-defined values of properties of this ``ToDo``.
  fileprivate init(describedBy descriptor: AnyToDoDescriptor) {
    var title = descriptor.title
    normalize(title: &title)
    self.title = title
    var summary = descriptor.summary
    normalize(summary: &summary)
    self.summary = summary
    self.status = descriptor.status
    self.deadline = descriptor.deadline
  }

  public mutating func setTitle(to newTitle: String) async throws {
    var newTitle = newTitle
    normalize(title: &newTitle)
    title = newTitle
  }

  public mutating func setSummary(to newSummary: String) async throws {
    var newSummary = newSummary
    normalize(summary: &newSummary)
    summary = newSummary
  }

  public mutating func setStatus(to newStatus: Status) async throws {
    status = newStatus
  }
  public mutating func setDeadline(to newDeadline: Date) async throws {
    deadline = newDeadline
  }
}
