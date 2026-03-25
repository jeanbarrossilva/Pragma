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

/// Implementation-agnostic information about a ``Plan``.
public struct AnyPlanDescriptor: Codable, Hashable, Sendable {
  /// Main, general, non-blank summary.
  public let title: String

  /// Secondary, detailed explanation related to the contents of the ``title``.
  /// May be blank.
  public let summary: String

  /// Each of the goals laid out, whose achievement was deemed required by the
  /// user in order for this plan to be successful. Their sorting in the array
  /// is the same as that of the ``Plan/goals`` of a ``Plan``.
  public let goals: [AnyGoalDescriptor]

  /// Initializes a type-erased ``PlanDescriptor`` based on a ``Plan``.
  ///
  /// - Parameter plan: ``Plan`` from which the type-erased ``PlanDescriptor``
  /// will be initialized.
  public init<PlanType>(of plan: PlanType) async throws where PlanType: Plan {
    self = .init(
      title: plan.title,
      summary: plan.summary,
      goals: try await plan.goals.asyncMap { goal in try await .init(of: goal) }
    )
  }

  /// Initializes a type-erased ``PlanDescriptor``.
  ///
  /// - Parameters:
  ///   - title: Main, general, non-blank summary.
  ///   - summary: Secondary, detailed explanation related to the contents of
  ///     the `title`. May be blank.
  ///   - goals: Each of the goals laid out, whose achievement was deemed
  ///     required by the user in order for the to be successful.
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
      && lhs.summary[lhs.summary.startIndex]
        < rhs.summary[rhs.summary.startIndex]
      && lhs.goals.count < rhs.goals.count
    if let lhsFirstGoal = lhs.goals.first, let rhsFirstGoal = rhs.goals.first {
      isLhsLesser = isLhsLesser && lhsFirstGoal < rhsFirstGoal
    }
    return isLhsLesser
  }
}

extension AnyPlanDescriptor: CustomStringConvertible {
  public var description: String { description(withGoalsIndentedBy: 1) }

  /// Produces a representation of this type-erased ``PlanDescriptor`` as a
  /// string, indenting the description of its ``Goal``s according to the
  /// specified level.
  ///
  /// - Parameter toDoIndentationLevel: Amount of tab characters by which the
  ///   descriptions of the ``Goal``s of the ``Plan`` being described will be
  ///   prefixed.
  fileprivate func description(
    withGoalsIndentedBy goalIndentationLevel: Int
  ) -> String {
    var description = title
    guard !goals.isEmpty else { return description }
    let goalIndentation = String(repeating: "\t", count: goalIndentationLevel)
    description +=
      "\n"
      + goals.map { goal in
        goalIndentation + "└ \(goal.description(withToDosIndentedBy: 2))"
      }
      .joined(separator: "\n")
    return description
  }
}
