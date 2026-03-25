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

/// Plans are groups of ``Goal``s which may be related by category (e.g., an
/// academic plan, focused on studies of subjects of a given course and overall
/// enhancement of received grades) or time (e.g., a plan with resolutions for
/// the upcoming year).
public protocol Plan: Idea where GoalType.ID == ID, GoalType.ToDoType.ID == ID {
  /// Type of the descriptor of an instance of a ``GoalType``.
  associatedtype GoalDescriptor: Sendable

  /// Type of ``Goal``s by which this ``Plan`` is composed.
  associatedtype GoalType: Goal

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
