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
public protocol ToDo: Sendable, SendableMetatype {
  /// Type of the ``id``.
  associatedtype ID: Hashable & Sendable

  /// Identifier which distinguishes this ``ToDo`` from others in the same
  /// ``Goal``.
  var id: ID { get }

  /// Main, general, non-blank description.
  var title: String { get }

  /// Secondary, detailed explanation related to the contents of the ``title``.
  /// May be blank.
  var summary: String { get }

  /// Stage of completion of this ``ToDo``.
  var status: Status { get }

  /// Date until which this ``ToDo`` is expected to be done.
  var deadline: Date { get }

  /// Changes the ``title``.
  ///
  /// - Parameter newTitle: Title by which the current one will be replaced.
  mutating func setTitle(to newTitle: String) async throws

  /// Changes the ``summary``.
  ///
  /// - Parameter newSummary: Summary by which the current one will be replaced.
  mutating func setSummary(to newSummary: String) async throws

  /// Changes the ``status``.
  ///
  /// - Parameter newStatus: Status by which the current one will be replaced.
  mutating func setStatus(to newStatus: Status) async throws

  /// Changes the ``deadline``.
  ///
  /// - Parameter newDeadline: Deadline by which the current one will be replaced.
  mutating func setDeadline(to newDeadline: Date) async throws
}
