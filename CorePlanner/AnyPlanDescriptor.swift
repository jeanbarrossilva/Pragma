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

/// Implementation-agnostic information about a ``Plan``.
public struct AnyPlanDescriptor: Codable, Hashable, Sendable {
  /// Main, general, non-blank summary.
  public let title: String

  /// Secondary, detailed explanation related to the contents of the ``title``. May be blank.
  public let summary: String

  /// Each of the goals laid out, whose achievement was deemed required by the user in order for
  /// this plan to be successful. Their sorting in the array is the same as that of the
  /// ``Plan/goals`` of a ``Plan``.
  public let goals: [AnyGoalDescriptor]

  /// Initializes a type-erased ``PlanDescriptor`` based on a ``Plan``.
  ///
  /// - Parameter plan: ``Plan`` from which the type-erased ``PlanDescriptor`` will be initialized.
  public init<PlanType>(
    of plan: PlanType
  ) async throws(PlannerError<PlanType.ImplementationError>) where PlanType: Plan {
    self = .init(
      title: try await plan.title,
      summary: try await plan.summary,
      goals: try await unsafe callWithTypedThrowsCast(
        to: PlannerError<PlanType.ImplementationError>.self
      ) {
        try await plan.goals.asyncMap { goal in try await .init(of: goal) }
      }
    )
  }

  /// Initializes a type-erased ``PlanDescriptor``.
  ///
  /// - Parameters:
  ///   - title: Main, general, non-blank summary.
  ///   - summary: Secondary, detailed explanation related to the contents of the `title`. May be
  ///     blank.
  ///   - goals: Each of the goals laid out, whose achievement was deemed required by the user in
  ///     order for the to be successful.
  public init(title: String, summary: String, goals: [AnyGoalDescriptor] = []) {
    self.title = title
    self.summary = summary
    self.goals = goals.sorted()
  }
}

extension AnyPlanDescriptor: Comparable {
  public static func < (lhs: Self, rhs: Self) -> Bool {
    var isLhsLesser =
      lhs.title[lhs.title.startIndex] < rhs.title[rhs.title.startIndex]
      && lhs.summary[lhs.summary.startIndex] < rhs.summary[rhs.summary.startIndex]
      && lhs.goals.count < rhs.goals.count
    if let lhsFirstGoal = lhs.goals.first, let rhsFirstGoal = rhs.goals.first {
      isLhsLesser = isLhsLesser && lhsFirstGoal < rhsFirstGoal
    }
    return isLhsLesser
  }
}

extension AnyPlanDescriptor: CustomStringConvertible {
  public var description: String { description(withGoalsIndentedBy: 1) }

  /// Produces a representation of this type-erased ``PlanDescriptor`` as a string, indenting the
  /// description of its ``Goal``s according to the specified level.
  ///
  /// - Parameter toDoIndentationLevel: Amount of tab characters by which the descriptions of the
  ///   ``Goal``s of the ``Plan`` being described will be prefixed.
  fileprivate func description(withGoalsIndentedBy goalIndentationLevel: Int) -> String {
    var description = title
    guard !goals.isEmpty else { return description }
    let goalIndentation = String(repeating: "\t", count: goalIndentationLevel)
    description +=
      "\n"
      + goals
      .map { goal in goalIndentation + "└ \(goal.description(withToDosIndentedBy: 2))" }
      .joined(separator: "\n")
    return description
  }
}

/// Implementation-agnostic information about a ``Goal``.
public struct AnyGoalDescriptor: Codable, Hashable, Sendable {
  /// Main, general, non-blank summary.
  public let title: String

  /// Secondary, detailed explanation related to the contents of the ``title``. May be blank.
  public let summary: String

  /// To-dos related to the achievement of the defined objective, sorted ascendingly by their
  /// deadline. Their sorting in the array is the same as that of the ``Goal/toDos`` of a ``Goal``.
  public let toDos: [AnyToDoDescriptor]

  /// Initializes a type-erased ``GoalDescriptor`` based on a ``Goal``.
  ///
  /// - Parameter goal: ``Goal`` from which the type-erased ``GoalDescriptor`` will be initialized.
  public init<GoalType>(of goal: GoalType) async throws(PlannerError<GoalType.ImplementationError>)
  where GoalType: Goal {
    self = .init(
      title: try await goal.title,
      summary: try await goal.summary,
      toDos: try await unsafe callWithTypedThrowsCast(
        to: PlannerError<GoalType.ImplementationError>.self
      ) {
        try await goal.toDos.asyncMap { toDo in try await .init(from: toDo) }
      }
    )
  }

  /// Initializes a type-erased ``GoalDescriptor``.
  ///
  /// - Parameters:
  ///   - title: Main, general, non-blank summary.
  ///   - summary: Secondary, detailed explanation related to the contents of the `title`. May be
  ///     blank.
  ///   - toDos: To-dos related to the achievement of the defined objective, sorted ascendingly by
  ///     their ``ReadOnlyToDo/deadline``.
  public init(title: String, summary: String, toDos: [AnyToDoDescriptor] = []) {
    self.title = title
    self.summary = summary
    self.toDos = toDos.sorted()
  }
}

extension AnyGoalDescriptor: Comparable {
  public static func < (lhs: Self, rhs: Self) -> Bool {
    var isLhsLesser =
      lhs.title[lhs.title.startIndex] < rhs.title[rhs.title.startIndex]
      && lhs.summary[lhs.summary.startIndex] < rhs.summary[rhs.summary.startIndex]
      && lhs.toDos.count < rhs.toDos.count
    if let lhsFirstToDo = lhs.toDos.first, let rhsFirstToDo = rhs.toDos.first {
      isLhsLesser = isLhsLesser && lhsFirstToDo < rhsFirstToDo
    }
    return isLhsLesser
  }
}

extension AnyGoalDescriptor: CustomStringConvertible {
  public var description: String { description(withToDosIndentedBy: 1) }

  /// Produces a representation of this type-erased ``GoalDescriptor`` as a string, indenting the
  /// description of its ``ToDo``s according to the specified level.
  ///
  /// - Parameter toDoIndentationLevel: Amount of tab characters by which the descriptions of the
  ///   ``ToDo``s of the ``Goal`` being described will be prefixed.
  fileprivate func description(withToDosIndentedBy toDoIndentationLevel: Int) -> String {
    var description = title
    guard !toDos.isEmpty else { return description }
    let toDoIndentation = String(repeating: "\t", count: toDoIndentationLevel)
    description +=
      "\n" + toDos.map { toDo in toDoIndentation + "└ \(toDo)" }.joined(separator: "\n")
    return description
  }
}

/// Implementation-agnostic information about a ``ToDo``.
public struct AnyToDoDescriptor: Codable, Hashable, Sendable {
  /// Main, general, non-blank summary.
  public let title: String

  /// Notes on the specifics of the achievement of this to-do, such as the prerequisites and prior
  /// preparations deemed necessary by the user. May also contain information about how it was done,
  /// detailing the process for mere posterior reading or as a basis for other plans.
  public let summary: String

  /// Stage of completion of this to-do.
  public let status: Status

  /// Date at which this to-do is expected to be or have been done.
  public let deadline: Date

  /// Initializes a type-erased ``ToDoDescriptor`` based on a ``ToDo``.
  ///
  /// - Parameter toDo: ``ToDo`` from which the type-erased ``ToDoDescriptor`` will be initialized.
  public init<ToDoType>(
    from toDo: ToDoType
  ) async throws(PlannerError<ToDoType.ImplementationError>) where ToDoType: ToDo {
    self = .init(
      title: try await toDo.title,
      summary: try await toDo.summary,
      status: try await toDo.status,
      deadline: try await toDo.deadline
    )
  }

  /// Initializes a type-erased ``ToDoDescriptor``.
  ///
  /// - Parameters:
  ///   - title: Main, general, non-blank summary.
  ///   - summary: Secondary, detailed explanation related to the contents of the `title`. May be
  ///     blank.
  ///   - status:  Stage of completion of the to-do.
  ///   - deadline: Date at which the to-do is expected to be or have been done.
  public init(title: String, summary: String, status: Status, deadline: Date) {
    self.title = title
    self.summary = summary
    self.status = status
    self.deadline = deadline
  }
}

extension AnyToDoDescriptor: Comparable {
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.deadline < rhs.deadline
      && lhs.title[lhs.title.startIndex] < rhs.title[rhs.title.startIndex]
      && lhs.summary[lhs.summary.startIndex] < rhs.summary[rhs.summary.startIndex]
  }
}

extension AnyToDoDescriptor: CustomStringConvertible {
  public var description: String {
    "\(status.icon) \(title)"
  }
}

extension Status {
  /// Unicode icon representing this status, displayed in the description of an
  /// ``AnyToDoDescriptor``.
  fileprivate var icon: Character {
    switch self {
    case .idle: "☐"
    case .ongoing: "⏱"
    case .done: "☑"
    }
  }
}
