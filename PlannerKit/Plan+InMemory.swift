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
public actor InMemoryPlanner: Planner {
  public typealias ImplementationError = NSError

  private(set) public var plans = [InMemoryPlan]()

  public func addPlan(
    titled title: String,
    summarizedBy summary: String
  ) throws(PlannerError<NSError>) -> UUID {
    let plan = InMemoryPlan(title: title, summary: summary)
    plans.append(plan)
    return plan.id
  }

  public func plan(identifiedAs id: UUID) throws(PlannerError<NSError>) -> InMemoryPlan {
    guard let plan = plans.first(where: { plan in plan.id == id })
    else { throw .nonexistent(type: InMemoryPlan.self, id: id) }
    return plan
  }

  public func removePlan(identifiedAs id: UUID) throws(PlannerError<NSError>) {
    guard let index = plans.firstIndex(where: { plan in plan.id == id }) else { return }
    plans.remove(at: index)
  }

  public func clear() throws(PlannerError<NSError>) { plans.removeAll() }
}

/// Plan whose modifications, including those on its goals and to-dos, are performed in-memory,
/// maintained only for as long as the program is being executed, with changes on these structs
/// being discarded upon their deinitialization.
public actor InMemoryPlan: Plan {
  public typealias ImplementationError = NSError

  public let id = UUID()
  public private(set) var title: String
  public private(set) var summary: String
  public private(set) var goals: [InMemoryGoal]

  public static let description = "plan"

  fileprivate init(title: String, summary: String, goals: [InMemoryGoal] = []) {
    var title = title
    Self.normalize(title: &title)
    self.title = title
    var summary = summary
    Self.normalize(summary: &summary)
    self.summary = summary
    self.goals = goals
  }

  public func setTitle(to newTitle: String) async throws(PlannerError<NSError>) {
    var newTitle = newTitle
    Self.normalize(title: &newTitle)
    title = newTitle
  }

  public func setSummary(to newSummary: String) async throws(PlannerError<NSError>) {
    var newSummary = newSummary
    Self.normalize(summary: &newSummary)
    summary = newSummary
  }

  public func addGoal(
    titled title: String,
    summarizedBy summary: String
  ) async throws(PlannerError<NSError>) -> UUID {
    let goal = await InMemoryGoal(title: title, summary: summary)
    goals.append(goal)
    return goal.id
  }

  public func goal(identifiedAs id: UUID) async throws(PlannerError<NSError>) -> InMemoryGoal {
    guard let goal = goals.first(where: { goal in goal.id == id })
    else { throw .nonexistent(type: InMemoryGoal.self, id: id) }
    return goal
  }

  public func removeGoal(identifiedAs id: UUID) async throws(PlannerError<NSError>) {
    guard let index = goals.firstIndex(where: { goal in goal.id == id }) else { return }
    goals.remove(at: index)
  }
}

/// Goal whose modifications and those on its to-dos are performed in-memory, maintained only for as
/// long as the program is being executed, with changes on these structs being discarded upon their
/// deinitialization.
public actor InMemoryGoal: Goal {
  public typealias ImplementationError = NSError

  public let id = UUID()
  public private(set) var title: String
  public private(set) var summary: String
  public private(set) var toDos: [InMemoryToDo]

  public static let description = "goal"

  fileprivate init(title: String, summary: String, toDos: [InMemoryToDo] = []) async {
    var title = title
    Self.normalize(title: &title)
    self.title = title
    var summary = summary
    Self.normalize(summary: &summary)
    self.summary = summary
    self.toDos = toDos
  }

  public func setTitle(to newTitle: String) async throws(PlannerError<NSError>) {
    var newTitle = newTitle
    Self.normalize(title: &newTitle)
    title = newTitle
  }

  public func setSummary(to newSummary: String) async throws(PlannerError<NSError>) {
    var newSummary = newSummary
    Self.normalize(summary: &newSummary)
    summary = newSummary
  }

  public func addToDo(
    titled title: String,
    summarizedBy summary: String,
    due deadline: Date
  ) async throws(PlannerError<NSError>) -> UUID {
    let toDo = InMemoryToDo(title: title, summary: summary, deadline: deadline)
    toDos.append(toDo)
    return toDo.id
  }

  public func toDo(identifiedAs id: UUID) async throws(PlannerError<NSError>) -> InMemoryToDo {
    guard let toDo = toDos.first(where: { toDo in toDo.id == id })
    else { throw .nonexistent(type: InMemoryToDo.self, id: id) }
    return toDo
  }

  public func removeToDo(identifiedAs id: UUID) async throws(PlannerError<NSError>) {
    guard let index = toDos.firstIndex(where: { toDo in toDo.id == id }) else { return }
    toDos.remove(at: index)
  }
}

/// To-do of a ``DemoGoal`` whose modifications are performed in-memory, maintained for as long as
/// the program is being executed and discarted upon the deinitialization of this struct.
public actor InMemoryToDo: ToDo {
  public typealias ImplementationError = NSError

  public let id = UUID()
  public private(set) var title: String
  public private(set) var summary: String
  public private(set) var status: Status
  public private(set) var deadline: Date

  public static let description = "to-do"

  fileprivate init(title: String, summary: String, status: Status = .idle, deadline: Date) {
    var title = title
    Self.normalize(title: &title)
    self.title = title
    var summary = summary
    Self.normalize(summary: &summary)
    self.summary = summary
    self.status = status
    self.deadline = deadline
  }

  public func setTitle(to newTitle: String) async throws(PlannerError<NSError>) {
    var newTitle = newTitle
    Self.normalize(title: &newTitle)
    title = newTitle
  }

  public func setSummary(to newSummary: String) async throws(PlannerError<NSError>) {
    var newSummary = newSummary
    Self.normalize(summary: &newSummary)
    summary = newSummary
  }

  public func setStatus(to newStatus: Status) async throws(PlannerError<NSError>) {
    status = newStatus
  }

  public func setDeadline(to newDeadline: Date) async throws(PlannerError<NSError>) {
    deadline = newDeadline
  }
}
