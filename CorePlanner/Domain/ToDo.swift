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

/// Referred to as "tasks" to the user, to-dos are the minimal steps toward the
/// achievement of a ``Goal``. They are sequential, meaning that each is part of
/// a set of other to-dos which are designed to be done in order; such order is
/// ascending, determined by their ``deadline``.
public protocol ToDo: Idea {
  /// Stage of completion of this ``ToDo``.
  var status: Status { get set }

  /// Date until which this ``ToDo`` is expected to be done.
  var deadline: Date { get set }
}
