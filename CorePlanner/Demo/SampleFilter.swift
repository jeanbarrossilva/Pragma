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

/// Transformer of sample read-only versions of ``CorePlanner`` structures.
///
/// Finding the structures in an amalgam of others based solely on an array can be cumbersome. Apart
/// from the boilerplate predicate itself, which may have to be written multiple times throughout
/// various places, the unavoidable force-unwrapping or handing of errors of data which is implied
/// to have been included in the samples, if it crashes, will often not provide an explanation as to
/// why.
///
/// As an example, consider the scenario in which you want to obtain the sample plan that has a goal
/// containing at least one to-do. Two attempts will be showcased: without sample filters, and with
/// them.
///
/// Without sample filters:
///
/// ```swift
/// let plan: AnyPlanDescriptor = .samples.first(where: { plan in
///   !plan.goals.isEmpty && plan.goals.contains(where: { goal in !goal.toDos.isEmpty })
/// })!
/// ```
///
/// This is harder to read than it needs to be. Worse: how is the caller supposed to know that a
/// plan matching that predicate does, in fact, exist? In this specific case, the assumption is
/// correct, but there is no way of knowing rather than reading the samples or, rather, running the
/// code: either it is obtained and execution continues normally; or that expression causes the
/// program to terminate, given the forced unwrap.
///
/// Now, with sample filters:
///
/// ```swift
/// let plan: AnyPlanDescriptor = .sample(.withGoals(.withToDos))
/// ```
///
/// A sample filter is a contract between its samples and you, the developer reading them. They
/// guarantee that, for a given predicate which they describe, there will be one or multiple
/// elements matching it.
///
/// - SeeAlso:
///   - ``AnyPlanDescriptor``
///   - ``AnyGoalDescriptor``
///   - ``AnyToDoDescriptor``
public protocol SampleFilter {
  /// Consequence of having filtered an array of ``Target``s.
  typealias Result = Target

  /// The element in the array of samples being transformed.
  associatedtype Target: Codable & Sendable

  /// The message with which the program will be terminated in case the contract of the predicate
  /// of this filter is broken. Such termination should never occur, as one of the purposes of a
  /// filter is guaranteing that one or more ``Target``s *will* be matched by it.
  static var _errorMessage: String { get }

  /// The predicate of this filter, determining whether a given ``Target`` is a match.
  ///
  /// - Returns: `true` when the `target` matches the predicate; otherwise, `false`. It will not
  ///   match in either of two scenarios:
  ///
  ///   1. This filter is being used only as a predicate — as an argument to another filter — and
  ///      some aspect of a ``Target`` of the parent filter did not match the predicate of this
  ///      one, the child filter. For example, in
  ///
  ///      ```swift
  ///      AnyPlanDescriptor.sample(.withGoals(.withToDos))
  ///      ```
  ///
  ///      where ``GoalWithToDosFilter/withToDos`` is used to filter goals without to-dos out from
  ///      the transformation. In this case, if `self` is the ``GoalWithToDosFilter/withToDos``
  ///      filter, it returning `nil` denotes that all goals of one specific plan are empty (i.e.,
  ///      do not contain to-dos); the ``PlanWithGoalsFilter/withGoals`` will, then, continue onto
  ///      the next plan.
  ///   2. The contract of the predicate of this filter is broken. Here, calls to this function
  ///      *should* terminate the program.
  func isMatch(_ target: Target) -> Bool
}

extension SampleFilter {
  /// Transforms an array of ``Target``s, obtaining one or more ``Target``s which match the
  /// predicate of this filter, terminating the program in case the contract of the
  /// predicate has been broken.
  ///
  /// This function should not be called by callers external to the implementation of a filter; call
  /// the static `Target/sample(_:)` instead, passing this filter in as the argument. For example,
  /// referencing a ``PlanWithGoalsFilter`` directly and calling this function on it, as in
  ///
  /// ```swift
  /// let plan: AnyPlanDescriptor = PlanWithGoalsFilter()._apply(to: .samples)
  /// ```
  ///
  /// is discouraged (and also defeats one of the purposes of a filter of enhancing readability).
  /// Rather, in this case, ``ReadOnlyPlan/sample(_:)`` is the function that should be called, and
  /// an instance of the filter should be given by accessing the static variable:
  ///
  /// ```swift
  /// let plan: AnyPlanDescriptor = .sample(.withGoals)
  /// ```
  ///
  /// - Parameter targets: Samples to be transformed into a ``Result``.
  /// - Returns: The result of having transformed the `targets` .
  func _apply(to targets: [Target]) -> Result {
    guard let result = targets.first(where: isMatch) else { fatalError(Self._errorMessage) }
    return result
  }
}
