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

/// Characteristics of a desired outcome, consisting of an obligatory, non-empty ``Headlined/title``
/// and an initially-empty set of ``toDos`` (referred to as "tasks" to the user). It intends to make
/// specific an otherwise broad objective, e.g., "work at Apple", by dividing it into various
/// intentional, trackable, time-constrained steps.
public protocol Goal: Comparable, Hashable, Headlined, Identifiable {
  /// Type of the ``ToDo``s by which this ``Goal`` is composed.
  associatedtype ToDoType: ToDo

  /// ``ToDo``s related to the achievement of the defined objective, sorted ascendingly by their
  /// deadline.
  ///
  /// ###### Implementation notes
  ///
  /// The ``ToDo``s *must* to be sorted and, even though this is an array, each of them *must* be
  /// unique, at least with an ID distinct from that of the other ones. Such uniqueness *must* be
  /// ensured by the public initializer or factory function.
  ///
  /// - SeeAlso: ``ToDo/deadline``
  var toDos: [ToDoType] { get }

  /// Changes the ``Headlined/title``.
  ///
  /// - Parameter newTitle: Title by which the current one will be replaced.
  mutating func setTitle(to newTitle: String) async

  /// Changes the ``description``.
  ///
  /// - Parameter newDescription: Description by which the current one will be replaced.
  mutating func setDescription(to newDescription: String) async

  /// Adds a ``ToDo`` to this ``Goal``.
  ///
  /// ###### Implementation notes
  ///
  /// The array returned by ``toDos`` *must* have been modified after a call to this function, with
  /// the ``ToDo`` included in it. By the time this function returns, such array *must* be sorted
  /// according to the deadline of each ``ToDo``.
  ///
  /// - Parameter toDo: ``ToDo`` to be added.
  /// - Returns: The ID generated for the added ``ToDo``.
  /// - SeeAlso: ``ToDo/deadline``
  mutating func addToDo(
    titled title: String,
    describedAs description: String,
    due deadline: Date
  ) async -> ToDoType.ID

  /// Removes the specified ``ToDo`` from this ``Goal``.
  ///
  /// ###### Implementation notes
  ///
  /// The array returned by ``toDos`` *must* have been modified after a call to this function, with
  /// the ``ToDo`` removed from it. By the time this function returns, such array *must* be sorted
  /// according to the deadline of each ``ToDo``.
  ///
  /// - Parameter id: ID of the ``ToDo`` to be removed.
  mutating func removeToDo(identifiedAs id: ToDoType.ID) async
}

extension Goal where Self: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
}

extension Goal where Self: Hashable {
  public func hash(into hasher: inout Hasher) {
    id.hash(into: &hasher)
    title.hash(into: &hasher)
    description.hash(into: &hasher)
    toDos.hash(into: &hasher)
  }
}

/// Referred to as "tasks" to the user, to-dos are the minimal steps toward the achievement of a
/// ``Goal``. They are sequential, meaning that each is part of a set of other to-dos which are
/// designed to be done in order; such order is ascending, determined by their ``deadline``.
public protocol ToDo: Comparable, Hashable, Headlined, Identifiable {
  /// Notes on the specifics of the achievement of this ``ToDo``, such as the prerequisites and
  /// prior preparations deemed necessary by the user. May also contain information about how it was
  /// done, detailing the process for mere posterior reading or as a basis for other plans.
  var description: String { get }

  /// Date at which this ``ToDo`` is expected to have been or be done.
  var deadline: Date { get }

  /// Whether this ``ToDo`` has been done.
  var isDone: Bool { get }

  /// Changes the ``Headlined/title``.
  ///
  /// - Parameter newTitle: Title by which the current one will be replaced.
  mutating func setTitle(to newTitle: String) async

  /// Changes the ``description``.
  ///
  /// - Parameter newDescription: Description by which the current one will be replaced.
  mutating func setDescription(to newDescription: String) async

  /// Changes the ``deadline``.
  ///
  /// - Parameter newDeadline: Deadline by which the current one will be replaced.
  mutating func setDeadline(to newDeadline: Date) async

  /// Marks this ``ToDo`` as done in case it is not done; otherwise, marks it as not done.
  ///
  /// - SeeAlso: ``isDone``
  mutating func toggle() async
}

extension ToDo where Self: Comparable {
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.deadline < rhs.deadline && lhs.isLesser(than: rhs)
  }
}

extension ToDo where Self: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
}

extension ToDo where Self: Hashable {
  public func hash(into hasher: inout Hasher) {
    id.hash(into: &hasher)
    title.hash(into: &hasher)
    description.hash(into: &hasher)
    deadline.hash(into: &hasher)
    isDone.hash(into: &hasher)
  }
}

public protocol Headlined {
  /// Main, general, non-blank description.
  var title: String { get }

  /// Secondary, detailed explanation related to the contents of the ``title``. May be blank.
  var description: String { get }
}

extension Headlined where Self: Comparable {
  /// Default implementation of ``<(_:_:)``.
  ///
  /// - Parameter other: Right-hand-side of the comparison.
  fileprivate func isLesser(than other: Self) -> Bool {
    title[title.startIndex] < other.title[other.title.startIndex]
      && description[description.startIndex] < other.description[other.description.startIndex]
  }

  public static func < (lhs: Self, rhs: Self) -> Bool { lhs.isLesser(than: rhs) }
}
