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

/// Implementation-agnostic information about a ``Goal``.
public struct AnyGoalDescriptor: Codable, Hashable, Sendable {
  /// Main, general, non-blank summary.
  public let title: String

  /// Secondary, detailed explanation related to the contents of the ``title``.
  /// May be blank.
  public let summary: String

  /// To-dos related to the achievement of the defined objective, sorted
  /// ascendingly by their deadline. Their sorting in the array is the same as
  /// that of the ``Goal/toDos`` of a ``Goal``.
  public let toDos: [AnyToDoDescriptor]

  /// Initializes a type-erased ``GoalDescriptor`` based on a ``Goal``.
  ///
  /// - Parameter goal: ``Goal`` from which the type-erased ``GoalDescriptor``
  ///   will be initialized.
  public init<GoalType>(of goal: GoalType) async throws where GoalType: Goal {
    self = .init(
      title: goal.title,
      summary: goal.summary,
      toDos: try await goal.toDos.asyncMap { toDo in try await .init(from: toDo)
      }
    )
  }

  /// Initializes a type-erased ``GoalDescriptor``.
  ///
  /// - Parameters:
  ///   - title: Main, general, non-blank summary.
  ///   - summary: Secondary, detailed explanation related to the contents of
  ///     the `title`. May be blank.
  ///   - toDos: To-dos related to the achievement of the defined objective,
  ///     sorted ascendingly by their ``ReadOnlyToDo/deadline``.
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
      && lhs.summary[lhs.summary.startIndex]
        < rhs.summary[rhs.summary.startIndex]
      && lhs.toDos.count < rhs.toDos.count
    if let lhsFirstToDo = lhs.toDos.first, let rhsFirstToDo = rhs.toDos.first {
      isLhsLesser = isLhsLesser && lhsFirstToDo < rhsFirstToDo
    }
    return isLhsLesser
  }
}

extension AnyGoalDescriptor: CustomStringConvertible {
  public var description: String { description(withToDosIndentedBy: 1) }

  /// Produces a representation of this type-erased ``GoalDescriptor`` as a
  /// string, indenting the description of its ``ToDo``s according to
  /// specified level.
  ///
  /// - Parameter toDoIndentationLevel: Amount of tab characters by which the
  ///   descriptions of the ``ToDo``s of the ``Goal`` being described will be
  ///   prefixed.
  func description(withToDosIndentedBy toDoIndentationLevel: Int) -> String {
    var description = title
    guard !toDos.isEmpty else { return description }
    let toDoIndentation = String(repeating: "\t", count: toDoIndentationLevel)
    description +=
      "\n"
      + toDos.map { toDo in toDoIndentation + "└ \(toDo)" }
      .joined(separator: "\n")
    return description
  }
}
