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

extension AnyPlanDescriptor {
  /// Obtains one sample from the ``samples`` that matches the predicate of a filter.
  ///
  /// - Parameter filter: The filter with which the matching sample will be obtained.
  public static func sample<Filter>(_ filter: Filter) -> Filter.Result
  where Filter: SamplePlanFilter {
    filter._apply(to: Self.samples)
  }
}

/// ``SampleFilter`` of plans.
public protocol SamplePlanFilter: SampleFilter where Target == AnyPlanDescriptor {}

// MARK: - .withoutGoals

extension SamplePlanFilter where Self == SamplePlanWithoutGoalsFilter {
  /// Filter for obtaining a plan without goals.
  public static var withoutGoals: Self { .init() }
}

/// Filter of ``withoutGoals``.
public struct SamplePlanWithoutGoalsFilter: SamplePlanFilter {
  public static let _errorMessage = "No plan without goals found."

  public func isMatch(_ target: AnyPlanDescriptor) -> Bool { target.goals.isEmpty }
}

// MARK: - .withGoals

extension SamplePlanFilter where Self == SamplePlanWithGoalsFilter {
  /// Filter for obtaining the plan with at least one goal.
  public static var withGoals: Self { .init(nil) }

  /// Filter for obtaining the plan with at least one goal matching the given filter.
  ///
  /// - Parameter goals: Filter serving as a predicate which a goal of the plan should match in
  ///   order for that plan to be the resulting one.
  public static func withGoals(_ goals: any SampleGoalFilter) -> Self { .init(goals) }
}

/// Filter of ``withGoals(_:)``.
public struct SamplePlanWithGoalsFilter: SamplePlanFilter {
  let goals: (any SampleGoalFilter)?

  init(_ goals: (any SampleGoalFilter)?) { self.goals = goals }

  public static var _errorMessage: String { "No plan with goals found." }

  public func isMatch(_ target: AnyPlanDescriptor) -> Bool {
    guard let goals else { return !target.goals.isEmpty }
    return target.goals.contains(where: goals.isMatch)
  }
}
