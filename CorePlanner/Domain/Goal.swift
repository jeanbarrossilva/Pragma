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

/// Characteristics of a desired outcome, consisting of an obligatory, non-empty
/// ``title`` and an initially-empty set of ``toDos`` (referred to as "tasks" to
/// the user). It intends to make specific an otherwise broad objective, e.g.,
/// "Work at Apple", by dividing it into various intentional, trackable,
/// time-constrained steps.
public protocol Goal: Sendable, SendableMetatype where ID == ToDoType.ID {
  /// Type of the descriptor of an instance of a ``ToDoType``.
  associatedtype ToDoDescriptor: Sendable

  /// Type of ``ToDo``s by which this ``Goal`` is composed.
  associatedtype ToDoType: ToDo

  /// Type of the ``id``.
  associatedtype ID: Hashable & Sendable

  /// Identifier which distinguishes this ``Goal`` from others in the same
  /// ``Plan``.
  var id: ID { get }

  /// Main, general, non-blank description.
  var title: String { get }

  /// Secondary, detailed explanation related to the contents of the ``title``.
  /// May be blank.
  var summary: String { get }

  /// ``ToDo``s related to the achievement of the defined objective, sorted
  /// ascendingly by their ``ToDo/deadline``.
  ///
  /// ###### Implementation notes
  ///
  /// The ``ToDo``s *must* be sorted and, even though this is an array, each of
  /// them *must* be unique, at least with an ID distinct from that of the other
  /// ones. Such uniqueness *must* be ensured by the public initializer or
  /// factory function.
  var toDos: [ToDoType] { get async throws }

  /// Changes the ``title``.
  ///
  /// - Parameter newTitle: Title by which the current one will be replaced.
  mutating func setTitle(to newTitle: String) async throws

  /// Changes the ``summary``.
  ///
  /// - Parameter newSummary: Summary by which the current one will be replaced.
  mutating func setSummary(to newSummary: String) async throws

  /// Adds a ``ToDo`` as described by its descriptor.
  ///
  /// ###### Implementation notes
  ///
  /// The array returned by ``toDos`` *must* have been modified after a call to
  /// this function, with the ``ToDo`` included in it. By the time this function
  /// returns, such array *must* be sorted according to the criteria of
  /// comparison of the type of ``ToDo``.
  ///
  /// - Parameter descriptor: Descriptor based on which the ``ToDo`` will be
  ///   added.
  /// - Returns: The ID of the added ``ToDo``.
  mutating func addToDo(
    describedBy descriptor: ToDoDescriptor
  ) async throws -> ID

  /// Retrieves an added ``ToDo`` identified with a given ID.
  ///
  /// - Parameter id: ID of the ``ToDo`` to be retrieved.
  /// - Throws: If the ``ToDo`` is not found.
  func toDo(identifiedAs id: ToDoType.ID) async throws -> ToDoType

  /// Removes the specified ``ToDo`` from this ``Goal``.
  ///
  /// ###### Implementation notes
  ///
  /// The array returned by ``toDos`` *must* have been modified after a call to
  /// this function, with the ``ToDo`` removed from it. By the time this
  /// function returns, such array *must* be sorted according to the criteria of
  /// comparison of the type of ``ToDo``.
  ///
  /// - Parameter id: ID of the ``ToDo`` to be removed.
  mutating func removeToDo(identifiedAs id: ToDoType.ID) async throws
}
