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

/// Stage of completion of a ``ToDo`` which determines whether such ``ToDo`` is
/// *idle*, *ongoing* or *done*.
@frozen
public enum Status: CaseIterable, Codable, Comparable {
  /// ``Status`` of a ``ToDo`` when none has been set.
  public static let `default` = Self.idle

  /// Denotes that the ``ToDo`` has been added to the ``Goal``, but no progress
  /// on it has been done yet.
  case idle

  /// Denotes that the ``ToDo`` is being worked on and is not yet done.
  case ongoing

  /// Denotes that the ``ToDo`` has been worked on and is done.
  case done
}
