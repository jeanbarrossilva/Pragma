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

/// Implementation-agnostic information about a ``ToDo``.
public struct AnyToDoDescriptor: Codable, Hashable, Sendable {
  /// Main, general, non-blank summary.
  public let title: String

  /// Notes on the specifics of the achievement of this to-do, such as the
  /// prerequisites and prior preparations deemed necessary by the user. May
  /// also contain information about how it was done, detailing the process for
  /// mere posterior reading or as a basis for other plans.
  public let summary: String

  /// Stage of completion of this to-do.
  public let status: Status

  /// Date at which this to-do is expected to be or have been done.
  public let deadline: Date

  /// Initializes a type-erased ``ToDoDescriptor`` based on a ``ToDo``.
  ///
  /// - Parameter toDo: ``ToDo`` from which the type-erased ``ToDoDescriptor``
  /// will be initialized.
  public init<ToDoType>(from toDo: ToDoType) async throws where ToDoType: ToDo {
    self = .init(
      title: toDo.title,
      summary: toDo.summary,
      status: toDo.status,
      deadline: toDo.deadline
    )
  }

  /// Initializes a type-erased ``ToDoDescriptor``.
  ///
  /// - Parameters:
  ///   - title: Main, general, non-blank summary.
  ///   - summary: Secondary, detailed explanation related to the contents of
  ///     the `title`. May be blank.
  ///   - status:  Stage of completion of the to-do.
  ///   - deadline: Date at which the to-do is expected to be or have been done.
  public init(title: String, summary: String, status: Status, deadline: Date) {
    self.title = title
    self.summary = summary
    self.status = status
    self.deadline = deadline
  }
}

extension AnyToDoDescriptor: Comparable {
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.deadline < rhs.deadline
      && lhs.title[lhs.title.startIndex] < rhs.title[rhs.title.startIndex]
      && lhs.summary[lhs.summary.startIndex]
        < rhs.summary[rhs.summary.startIndex]
  }
}

extension AnyToDoDescriptor: CustomStringConvertible {
  public var description: String { "\(status.icon) \(title)" }
}

extension Status {
  /// Unicode icon representing this status, displayed in the description of an
  /// ``AnyToDoDescriptor``.
  fileprivate var icon: Character {
    switch self {
    case .idle: "☐"
    case .ongoing: "⏱"
    case .done: "☑"
    }
  }
}
