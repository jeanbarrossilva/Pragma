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

/// Abstract container into which plans can be added, providing the ability to
/// retrieve them afterwards. The mechanism for adding and whether the plans or
/// changes to them are maintained after deinitialization of an instance of this
/// type or of its plans is a detail of the implementation.
public protocol PlanRepository
where
  PlanType.ID == PlanType.GoalType.ID,
  PlanType.GoalType.ID == PlanType.GoalType.ToDoType.ID
{
  /// Type of the descriptor of an instance of a ``PlanType``.
  associatedtype PlanDescriptor: Sendable

  /// Type of ``Plan``s by which this ``PlanRepository`` is composed.
  associatedtype PlanType: Plan

  /// Stream of ``Plan``s in this ``PlanRepository``.
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

  /// Removes an added plan from this ``PlanRepository``.
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

  /// Removes every added plan, goal and to-do from this ``PlanRepository``.
  ///
  /// > Warning: This is a destructive action and cannot be undone.
  mutating func clear() async throws
}
