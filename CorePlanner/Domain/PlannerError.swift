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
  case nonexistent(type: any Idea.Type, id: any Hashable & Sendable)
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
