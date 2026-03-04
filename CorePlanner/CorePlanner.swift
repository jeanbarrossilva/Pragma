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

@_exported import Foundation

/// Abstract container into which plans can be added, providing the ability to
/// retrieve them afterwards. The mechanism for adding and whether the plans or
/// changes to them are maintained after deinitialization of an instance of this
/// type or of its plans is a detail of the implementation.
public protocol Planner
where
  PlanType.ID == PlanType.GoalType.ID,
  PlanType.GoalType.ID == PlanType.GoalType.ToDoType.ID
{
  /// Type of the descriptor of an instance of a ``PlanType``.
  associatedtype PlanDescriptor: Sendable

  /// Type of ``Plan``s by which this ``Planner`` is composed.
  associatedtype PlanType: Plan

  /// Stream of ``Plan``s in this ``Planner``.
  ///
  /// ###### Implementation notes
  ///
  /// The ``Plan``s *must* be sorted and, even though this is an array, each of
  /// them *must* be unique, at least with an ID distinct from that of the other
  /// ones. Such uniqueness *must* be ensured by the public initializer or
  /// factory function.
  var plans: [PlanType] { get async throws }

  /// Adds a ``Plan`` as described by its descriptor. All ``Goal``s described in
  /// it, alongside the ``ToDo``s defined within these goals, will also be
  /// added.
  ///
  /// ###### Implementation notes
  ///
  /// The array returned by ``plans`` *must* have been modified after a call to
  /// this function, with the ``Plan`` included in it. By the time this function
  /// returns, such array *must* be sorted according to the criteria of
  /// comparison of the type of ``Plan``.
  ///
  /// - Parameter descriptor: Descriptor based on which the ``Plan`` will be
  ///   added.
  /// - Returns: The ID of the added ``Plan``.
  /// - SeeAlso: ``addGoal(describedBy:)``
  mutating func addPlan(
    describedBy descriptor: PlanDescriptor
  ) async throws -> PlanType.ID

  /// Removes an added plan from this ``Planner``.
  ///
  /// ###### Implementation notes
  ///
  /// The array returned by ``plans`` *must* have been modified after a call to
  /// this function, with the ``Plan`` removed from it. By the time this
  /// function returns, such array *must* be sorted according to the criteria of
  /// comparison of the type of ``Plan``.
  ///
  /// - Parameter id: ID of the plan to be deleted.
  mutating func removePlan(identifiedAs id: PlanType.ID) async throws

  /// Retrieves an added ``Plan`` identified with a given ID.
  ///
  /// - Parameter id: ID of the ``Plan`` to be retrieved.
  /// - Throws: If the ``Plan`` is not found.
  func plan(identifiedAs id: PlanType.ID) async throws -> PlanType

  /// Removes every added plan, goal and to-do from this ``Planner``.
  ///
  /// > Warning: This is a destructive action and cannot be undone.
  mutating func clear() async throws
}

/// Plans are groups of ``Goal``s which may be related by category (e.g., an
/// academic plan, focused on studies of subjects of a given course and overall
/// enhancement of received grades) or time (e.g., a plan with resolutions for
/// the upcoming year).
public protocol Plan: Sendable, SendableMetatype
where GoalType.ID == ID, GoalType.ToDoType.ID == ID {
  /// Type of the descriptor of an instance of a ``GoalType``.
  associatedtype GoalDescriptor: Sendable

  /// Type of ``Goal``s by which this ``Plan`` is composed.
  associatedtype GoalType: Goal

  /// Type of the ``id``.
  associatedtype ID: Hashable & Sendable

  /// Identifier which distinguishes this ``Plan`` from others in the same
  /// ``Planner``.
  var id: ID { get }

  /// Main, general, non-blank description.
  var title: String { get }

  /// Secondary, detailed explanation related to the contents of the ``title``.
  /// May be blank.
  var summary: String { get }

  /// Each of the ``Goal``s laid out, whose achievement was deemed required by
  /// the user in order for this ``Plan`` to be successful.
  ///
  /// ###### Implementation notes
  ///
  /// The ``Goal``s *must* be sorted and, even though this is an array, each of
  /// them *must* be unique, at least with an ID distinct from that of the other
  /// ones. Such uniqueness *must* be ensured by the public initializer or
  /// factory function.
  var goals: [GoalType] { get async throws }

  /// Changes the ``title``.
  ///
  /// - Parameter newTitle: Title by which the current one will be replaced.
  mutating func setTitle(to newTitle: String) async throws

  /// Changes the ``summary``.
  ///
  /// - Parameter newSummary: Summary by which the current one will be replaced.
  mutating func setSummary(to newSummary: String) async throws

  /// Adds a ``Goal`` as described by its descriptor. All ``ToDo``s described in
  /// it will also be added.
  ///
  /// ###### Implementation notes
  ///
  /// The array returned by ``goals`` *must* have been modified after a call to
  /// this function, with the ``Goal`` included in it. By the time this function
  /// returns, such array *must* be sorted according to the criteria of
  /// comparison of the type of ``Goal``.
  ///
  /// - Parameter descriptor: Descriptor based on which the ``Goal`` will be
  ///   added.
  /// - Returns: The ID of the added ``Goal``.
  /// - SeeAlso: ``addToDo(describedBy:)``
  mutating func addGoal(
    describedBy descriptor: GoalDescriptor
  ) async throws -> ID

  /// Retrieves an added ``Goal`` identified with a given ID.
  ///
  /// - Parameter id: ID of the ``Goal`` to be retrieved.
  /// - Throws: If the ``Goal`` is not found.
  func goal(identifiedAs id: GoalType.ID) async throws -> GoalType

  /// Removes the specified ``Goal`` from this ``Plan``.
  ///
  /// ###### Implementation notes
  ///
  /// The array returned by ``goals`` *must* have been modified after a call to
  /// this function, with the ``Goal`` removed from it. By the time this
  /// function returns, such array *must* be sorted according to the criteria of
  /// comparison of the type of ``Goal``.
  ///
  /// - Parameter id: ID of the ``Goal`` to be removed.
  mutating func removeGoal(identifiedAs id: GoalType.ID) async throws
}

/// Characteristics of a desired outcome, consisting of an obligatory, non-empty
/// ``title`` and an initially-empty set of ``toDos`` (referred to as "tasks" to
/// the user). It intends to make specific an otherwise broad objective, e.g.,
/// "Work at Apple", by dividing it into various intentional, trackable,
/// time-constrained steps.
public protocol Goal: Sendable, SendableMetatype where ID == ToDoType.ID {
  /// Type of the descriptor of an instance of a ``ToDoType``.
  associatedtype ToDoDescriptor: Sendable

  /// Type of ``ToDo``s by which this ``Goal`` is composed.
  associatedtype ToDoType: ToDo

  /// Type of the ``id``.
  associatedtype ID: Hashable & Sendable

  /// Identifier which distinguishes this ``Goal`` from others in the same
  /// ``Plan``.
  var id: ID { get }

  /// Main, general, non-blank description.
  var title: String { get }

  /// Secondary, detailed explanation related to the contents of the ``title``.
  /// May be blank.
  var summary: String { get }

  /// ``ToDo``s related to the achievement of the defined objective, sorted
  /// ascendingly by their ``ToDo/deadline``.
  ///
  /// ###### Implementation notes
  ///
  /// The ``ToDo``s *must* be sorted and, even though this is an array, each of
  /// them *must* be unique, at least with an ID distinct from that of the other
  /// ones. Such uniqueness *must* be ensured by the public initializer or
  /// factory function.
  var toDos: [ToDoType] { get async throws }

  /// Changes the ``title``.
  ///
  /// - Parameter newTitle: Title by which the current one will be replaced.
  mutating func setTitle(to newTitle: String) async throws

  /// Changes the ``summary``.
  ///
  /// - Parameter newSummary: Summary by which the current one will be replaced.
  mutating func setSummary(to newSummary: String) async throws

  /// Adds a ``ToDo`` as described by its descriptor.
  ///
  /// ###### Implementation notes
  ///
  /// The array returned by ``toDos`` *must* have been modified after a call to
  /// this function, with the ``ToDo`` included in it. By the time this function
  /// returns, such array *must* be sorted according to the criteria of
  /// comparison of the type of ``ToDo``.
  ///
  /// - Parameter descriptor: Descriptor based on which the ``ToDo`` will be
  ///   added.
  /// - Returns: The ID of the added ``ToDo``.
  mutating func addToDo(
    describedBy descriptor: ToDoDescriptor
  ) async throws -> ID

  /// Retrieves an added ``ToDo`` identified with a given ID.
  ///
  /// - Parameter id: ID of the ``ToDo`` to be retrieved.
  /// - Throws: If the ``ToDo`` is not found.
  func toDo(identifiedAs id: ToDoType.ID) async throws -> ToDoType

  /// Removes the specified ``ToDo`` from this ``Goal``.
  ///
  /// ###### Implementation notes
  ///
  /// The array returned by ``toDos`` *must* have been modified after a call to
  /// this function, with the ``ToDo`` removed from it. By the time this
  /// function returns, such array *must* be sorted according to the criteria of
  /// comparison of the type of ``ToDo``.
  ///
  /// - Parameter id: ID of the ``ToDo`` to be removed.
  mutating func removeToDo(identifiedAs id: ToDoType.ID) async throws
}

/// Referred to as "tasks" to the user, to-dos are the minimal steps toward the
/// achievement of a ``Goal``. They are sequential, meaning that each is part of
/// a set of other to-dos which are designed to be done in order; such order is
/// ascending, determined by their ``deadline``.
public protocol ToDo: Sendable, SendableMetatype {
  /// Type of the ``id``.
  associatedtype ID: Hashable & Sendable

  /// Identifier which distinguishes this ``ToDo`` from others in the same
  /// ``Goal``.
  var id: ID { get }

  /// Main, general, non-blank description.
  var title: String { get }

  /// Secondary, detailed explanation related to the contents of the ``title``.
  /// May be blank.
  var summary: String { get }

  /// Stage of completion of this ``ToDo``.
  var status: Status { get }

  /// Date until which this ``ToDo`` is expected to be done.
  var deadline: Date { get }

  /// Changes the ``title``.
  ///
  /// - Parameter newTitle: Title by which the current one will be replaced.
  mutating func setTitle(to newTitle: String) async throws

  /// Changes the ``summary``.
  ///
  /// - Parameter newSummary: Summary by which the current one will be replaced.
  mutating func setSummary(to newSummary: String) async throws

  /// Changes the ``status``.
  ///
  /// - Parameter newStatus: Status by which the current one will be replaced.
  mutating func setStatus(to newStatus: Status) async throws

  /// Changes the ``deadline``.
  ///
  /// - Parameter newDeadline: Deadline by which the current one will be replaced.
  mutating func setDeadline(to newDeadline: Date) async throws
}

/// Enum defining the discrete set of errors that can be thrown by every
/// implementation of a ``Plan`` or any of its related protocols. These errors
/// indicate that an instance of one of these protocols has gotten into a state
/// in which some operations cannot be performed and there is no plausible work
/// around that state to continue that operation.
public enum PlannerError: Error, @unchecked Sendable {
  /// An attempt to retrieve a ``Plan``, a ``Goal`` or a ``ToDo`` was made, but
  /// it was never added or got deleted.
  ///
  /// - Parameters:
  ///   - type: Type of the instance which was not found.
  ///   - id: The unique ID expected to be that of the nonexistent instance.
  case nonexistent(type: any Sendable.Type, id: any Hashable & Sendable)
}

extension PlannerError: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (
      .nonexistent(let lhsType, let lhsID), .nonexistent(let rhsType, let rhsID)
    ): lhsType == rhsType && AnyHashable(lhsID) == .init(rhsID)
    }
  }
}

/// Stage of completion of a to-do which determines whether such to-do is
/// *idle*, *ongoing* or *done*.
@frozen
public enum Status: CaseIterable, Codable, Comparable {
  /// ``Status`` of a ``ToDo`` when none has been set.
  public static let `default` = Self.idle

  /// Denotes that the to-do has been added to the goal, but no progress on it
  /// has been done yet.
  case idle

  /// Denotes that the to-do is being worked on and is not yet done.
  case ongoing

  /// Denotes that the to-do has been worked on and is done.
  case done
}
