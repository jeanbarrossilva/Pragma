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

// MARK: - .withoutToDos

extension AnyGoalDescriptor {
  /// Obtains one sample from the ``samples`` that matches the predicate of a filter.
  ///
  /// - Parameter filter: The filter with which the matching sample will be obtained.
  public static func sample<Filter>(_ filter: Filter) -> Filter.Result
  where Filter: SampleGoalFilter {
    filter._apply(to: Self.samples)
  }
}

/// Filter of ``withoutToDos``.
public struct SampleGoalWithoutToDosFilter: SampleGoalFilter {
  public static let _errorMessage = "No goal without to-dos found."

  public func isMatch(_ target: AnyGoalDescriptor) -> Bool { target.toDos.isEmpty }
}

/// ``SampleFilter`` of goals.
public protocol SampleGoalFilter: SampleFilter where Target == AnyGoalDescriptor {}

extension SampleGoalFilter where Self == SampleGoalWithoutToDosFilter {
  /// Filter for obtaining the goal without to-dos.
  public static var withoutToDos: Self { .init() }
}

// MARK: - .withToDos

/// Filter of ``withToDos``.
public struct SampleGoalWithToDosFilter: SampleGoalFilter {
  public static let _errorMessage = "No goal with to-dos found."

  public func isMatch(_ target: AnyGoalDescriptor) -> Bool { !target.toDos.isEmpty }
}

extension SampleGoalFilter where Self == SampleGoalWithToDosFilter {
  /// Filter for obtaining the goal with at least one to-do.
  public static var withToDos: Self { .init() }
}
