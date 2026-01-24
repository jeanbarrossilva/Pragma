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

/// Immutable view a ``Plan``.
public struct ReadOnlyPlan: Codable, Identifiable, Sendable {
  public let id: AnyCodable

  /// Main, general, non-blank summary.
  public let title: String

  /// Secondary, detailed explanation related to the contents of the ``title``. May be blank.
  public let summary: String

  /// Each of the ``Goal``s laid out, whose achievement was deemed required by the user in order for
  /// this plan to be successful. Their sorting in the array is the same as that of the original
  /// ``Plan/goals``.
  public let goals: [ReadOnlyGoal]

  public static var description: String { "plan" }

  /// Initializes a ``ReadOnlyPlan`` based on a ``Plan``.
  ///
  /// - Parameter plan: ``Plan`` from which this ``ReadOnlyPlan`` will be initialized.
  public init<PlanType>(
    from plan: PlanType
  ) async throws(PlannerError<PlanType.ImplementationError>)
  where
    PlanType: Plan,
    PlanType.ID: Codable,
    PlanType.GoalType.ID: Codable,
    PlanType.GoalType.ToDoType.ID: Codable
  {
    self = .init(
      id: plan.id as? AnyCodable ?? .init(plan.id),
      title: try await plan.title,
      summary: try await plan.summary,
      goals: try await unsafe callWithTypedThrowsCast(
        to: PlannerError<PlanType.ImplementationError>.self
      ) {
        try await plan.goals.asyncMap { goal in try await .init(from: goal) }
      }
    )
  }

  /// Initializes a ``ReadOnlyPlan``.
  ///
  /// - Parameters:
  ///   - id: The stable identity of the entity associated with the instance.
  ///   - title: Main, general, non-blank summary.
  ///   - summary: Secondary, detailed explanation related to the contents of the `title`. May be
  ///     blank.
  ///   - goals: Each of the goals laid out, whose achievement was deemed required by the user in
  ///     order for the to be successful.
  public init(id: AnyCodable, title: String, summary: String, goals: [ReadOnlyGoal]) {
    self.id = id
    self.title = title
    self.summary = summary
    self.goals = goals
  }
}

extension ReadOnlyPlan: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
}

/// Immutable view a goal of a plan.
public struct ReadOnlyGoal: Codable, Identifiable, Sendable {
  public let id: AnyCodable

  /// Main, general, non-blank summary.
  public let title: String

  /// Secondary, detailed explanation related to the contents of the ``title``. May be blank.
  public let summary: String

  /// To-dos related to the achievement of the defined objective, sorted ascendingly by their
  /// deadline. Their sorting in the array is the same as that of the original ``Goal/toDos``.
  public let toDos: [ReadOnlyToDo]

  public static var description: String { "goal" }

  /// Initializes a ``ReadOnlyGoal`` based on a ``Goal``.
  ///
  /// - Parameter goal: ``Goal`` from which this ``ReadOnlyGoal`` will be initialized.
  public init<GoalType>(
    from goal: GoalType
  ) async throws(PlannerError<GoalType.ImplementationError>)
  where GoalType: Goal, GoalType.ID: Codable, GoalType.ToDoType.ID: Codable {
    self = .init(
      id: goal.id as? AnyCodable ?? .init(goal.id),
      title: try await goal.title,
      summary: try await goal.summary,
      toDos: try await unsafe callWithTypedThrowsCast(
        to: PlannerError<GoalType.ImplementationError>.self
      ) {
        try await goal.toDos.asyncMap { toDo in try await .init(from: toDo) }
      }
    )
  }

  /// Initializes a ``ReadOnlyGoal``.
  ///
  /// - Parameters:
  ///   - id: The stable identity of the entity associated with the instance.
  ///   - title: Main, general, non-blank summary.
  ///   - summary: Secondary, detailed explanation related to the contents of the `title`. May be
  ///     blank.
  ///   - toDos: To-dos related to the achievement of the defined objective, sorted ascendingly by
  ///     their ``ReadOnlyToDo/deadline``.
  public init(id: AnyCodable, title: String, summary: String, toDos: [ReadOnlyToDo]) {
    self.id = id
    self.title = title
    self.summary = summary
    self.toDos = toDos
  }
}

extension ReadOnlyGoal: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
}

/// Immutable view of a to-do of a goal.
public struct ReadOnlyToDo: Codable, Hashable, Identifiable, Sendable {
  public let id: AnyCodable

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

  public static var description: String { "to-do" }

  /// Initializes a ``ReadOnlyToDo`` based on a ``ToDo``.
  ///
  /// - Parameter toDo: ``ToDo`` from which this ``ReadOnlyToDo`` will be initialized.
  public init<ToDoType>(
    from toDo: ToDoType
  ) async throws(PlannerError<ToDoType.ImplementationError>)
  where ToDoType: ToDo, ToDoType.ID: Codable {
    self = .init(
      id: toDo.id as? AnyCodable ?? .init(toDo.id),
      title: try await toDo.title,
      summary: try await toDo.summary,
      status: try await toDo.status,
      deadline: try await toDo.deadline
    )
  }

  /// Initializes a ``ReadOnlyToDo``.
  ///
  /// - Parameters:
  ///   - id: The stable identity of the entity associated with the instance.
  ///   - title: Main, general, non-blank summary.
  ///   - summary: Secondary, detailed explanation related to the contents of the `title`. May be
  ///     blank.
  ///   - status:  Stage of completion of the to-do.
  ///   - deadline: Date at which the to-do is expected to be or have been done.
  public init(id: AnyCodable, title: String, summary: String, status: Status, deadline: Date) {
    self.id = id
    self.title = title
    self.summary = summary
    self.status = status
    self.deadline = deadline
  }
}

extension ReadOnlyToDo: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
}
