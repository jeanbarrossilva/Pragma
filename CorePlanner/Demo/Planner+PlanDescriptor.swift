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

extension Planner {
  /// Adds a ``Plan`` as described by its descriptor. All ``Goal``s described in it, alongside the
  /// ``ToDo``s defined within these goals, will also be added.
  ///
  /// - Parameter descriptor: Descriptor based on which the ``Plan`` will be added.
  /// - Returns: The ID of the added ``Plan``.
  /// - SeeAlso: ``addGoal(describedBy:)``
  public func addPlan(
    describedBy descriptor: AnyPlanDescriptor
  ) async throws(PlannerError<ImplementationError>) -> PlanType.ID {
    let addedPlanID = try addPlan(titled: descriptor.title, summarizedBy: descriptor.summary)
    let addedPlan = try plan(identifiedAs: addedPlanID)
    for goalDescriptor in descriptor.goals {
      _ = try await addedPlan.addGoal(describedBy: goalDescriptor)
    }
    return addedPlanID
  }
}

extension Plan {
  /// Adds a ``Goal`` as described by its descriptor. All ``ToDo``s described in it will also be
  /// added.
  ///
  /// - Parameter descriptor: Descriptor based on which the ``Goal`` will be added.
  /// - Returns: The ID of the added ``Goal``.
  /// - SeeAlso: ``addToDo(describedBy:)``
  public func addGoal(
    describedBy descriptor: AnyGoalDescriptor
  ) async throws(PlannerError<ImplementationError>) -> GoalType.ID {
    let addedGoalID = try await addGoal(titled: descriptor.title, summarizedBy: descriptor.summary)
    let addedGoal = try await goal(identifiedAs: addedGoalID)
    for toDoDescriptor in descriptor.toDos {
      _ = try await addedGoal.addToDo(describedBy: toDoDescriptor)
    }
    return addedGoalID
  }
}

extension Goal {
  /// Adds a ``ToDo`` as described by its descriptor.
  ///
  /// - Parameter descriptor: Descriptor based on which the ``ToDo`` will be added.
  /// - Returns: The ID of the added ``ToDo``.
  public func addToDo(
    describedBy descriptor: AnyToDoDescriptor
  ) async throws(PlannerError<ImplementationError>) -> ToDoType.ID {
    let addedToDoID = try await addToDo(
      titled: descriptor.title,
      summarizedBy: descriptor.summary,
      due: descriptor.deadline
    )
    guard descriptor.status != .idle else { return addedToDoID }
    let addedToDo = try await toDo(identifiedAs: addedToDoID)
    try await addedToDo.setStatus(to: descriptor.status)
    return addedToDoID
  }
}
