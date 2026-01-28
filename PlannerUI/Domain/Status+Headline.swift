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

extension Status {
  /// General, short and displayable description of this status.
  var title: String {
    switch self {
    case .idle: "Idle"
    case .ongoing: "Ongoing"
    case .done: "Done"
    }
  }

  /// Detailed explanation of what this status means.
  var summary: String {
    switch self {
    case .idle: "The task will be added to the goal, but no progress on it has been done yet."
    case .ongoing: "The task is being worked on and is not yet done."
    case .done: "The task has been worked on and is done."
    }
  }
}
