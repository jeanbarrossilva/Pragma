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

import CorePlanner
import SwiftUI

internal import UniformTypeIdentifiers

/// Immutable metadata about a plan displayable by some client.
public struct ReadOnlyPlan: Headlined, @unchecked Sendable {
  public let id: AnyCodable
  public let title: String
  public let description: String

  /// Each of the goals laid out, whose achievement was deemed required by the user in order for
  /// this plan to be successful. Their sorting in the array is the same as that of the original
  /// ``CorePlanner/Plan/goals``.
  public let goals: [ReadOnlyGoal]

  public static var description: String { "plan" }

  /// Initializes a ``ReadOnlyPlan`` based on a plan.
  ///
  /// - Parameter plan: Plan from which this ``ReadOnlyPlan`` will be initialized.
  public init<Original>(from plan: Original)
  where
    Original: Plan, Original.ID: Codable & Sendable, Original.GoalType.ID: Codable & Sendable,
    Original.GoalType.ToDoType.ID: Codable & Sendable
  {
    self.id = plan.id as? AnyCodable ?? .init(plan.id)
    self.title = plan.title
    self.description = plan.description
    self.goals = plan.goals.map { goal in .init(from: goal) }
  }
}

/// Immutable metadata about a goal of a plan displayable by some client.
public struct ReadOnlyGoal: Headlined, @unchecked Sendable {
  public let id: AnyCodable
  public let title: String
  public let description: String

  /// To-dos related to the achievement of the defined objective, sorted ascendingly by their
  /// deadline. Their sorting in the array is the same as that of the original
  /// ``CorePlanner/Goal/toDos``.
  public let toDos: [ReadOnlyToDo]

  public static var description: String { "goal" }

  /// Initializes a ``ReadOnlyGoal`` based on a goal.
  ///
  /// - Parameter goal: Goal from which this ``ReadOnlyGoal`` will be initialized.
  public init<Original>(from goal: Original)
  where Original: Goal, Original.ID: Codable & Sendable, Original.ToDoType.ID: Codable & Sendable {
    self.id = goal.id as? AnyCodable ?? .init(goal.id)
    self.title = goal.title
    self.description = goal.description
    self.toDos = goal.toDos.map { toDo in .init(from: toDo) }
  }
}

/// Immutable metadata about a to-do of a goal displayable by some client.
public struct ReadOnlyToDo: Codable, Headlined, @unchecked Sendable {
  public let id: AnyCodable
  public let title: String

  /// Notes on the specifics of the achievement of this to-do, such as the prerequisites and prior
  /// preparations deemed necessary by the user. May also contain information about how it was done,
  /// detailing the process for mere posterior reading or as a basis for other plans.
  public let description: String

  /// Stage of completion of this to-do.
  let status: Status

  /// Date at which this to-do is expected to be or have been done.
  let deadline: Date

  public static var description: String { "to-do" }

  /// Initializes a ``ReadOnlyToDo`` based on a to-do.
  ///
  /// - Parameter toDo: Goal from which this ``ReadOnlyGoal`` will be initialized.
  public init<Original>(from toDo: Original) where Original: ToDo, Original.ID: Codable & Sendable {
    self.id = toDo.id as? AnyCodable ?? .init(toDo.id)
    self.title = toDo.title
    self.description = toDo.description
    self.status = toDo.status
    self.deadline = toDo.deadline
  }
}

extension ReadOnlyToDo: Transferable {
  public static var transferRepresentation: some TransferRepresentation {
    CodableRepresentation(contentType: .propertyList).visibility(.ownProcess)
  }
}
