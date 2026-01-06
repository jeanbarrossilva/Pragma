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

/// Plans are groups of ``Goal``s which may be related by category (e.g., an academic plan, focused
/// on studies of subjects of a given course and overall enhancement of received grades) or time
/// (e.g., a plan with resolutions for the upcoming year).
public protocol Plan: Headlined {
  /// Type of the ``Goal``s by which this ``Plan`` is composed.
  associatedtype GoalType: Goal

  /// Each of the ``Goal``s laid out, whose achievement was deemed required by the user in order for
  /// this ``Plan`` to be successful.
  ///
  /// ###### Implementation notes
  ///
  /// The ``Goal``s *must* be sorted and, even though this is an array, each of them *must* be
  /// unique, at least with an ID distinct from that of the other ones. Such uniqueness *must* be
  /// ensured by the public initializer or factory function.
  var goals: [GoalType] { get }

  /// Adds a ``Goal`` to this ``Plan``.
  ///
  /// ###### Implementation notes
  ///
  /// The array returned by ``goals`` *must* have been modified after a call to this function, with
  /// the ``Goal`` included in it. By the time this function returns, such array *must* be sorted
  /// according to the criteria of comparison of the type of ``Goal``.
  ///
  /// - Parameters:
  ///   - title: ``Headlined/title`` of the ``Goal``.
  ///   - description: ``Headlined/description`` of the ``Goal``.
  /// - Returns: The added ``Goal``.
  mutating func addGoal(titled title: String, describedAs description: String) async -> GoalType

  /// Removes the specified ``Goal`` from this ``Plan``.
  ///
  /// ###### Implementation notes
  ///
  /// The array returned by ``goals`` *must* have been modified after a call to this function, with
  /// the ``Goal`` included in it. By the time this function returns, such array *must* be sorted
  /// according to the criteria of comparison of the type of ``Goal``.
  ///
  /// - Parameter id: ID of the ``Goal`` to be removed.
  mutating func removeGoal(identifiedAs id: GoalType.ID) async
}

extension Plan where Self: Comparable {
  public static func < (lhs: Self, rhs: Self) -> Bool {
    var isLhsLesserThanRhs = lhs.isLesser(than: rhs)
    if let firstLhsGoal = lhs.goals.first, let firstRhsGoal = lhs.goals.first {
      isLhsLesserThanRhs = isLhsLesserThanRhs && firstLhsGoal < firstRhsGoal
    }
    return isLhsLesserThanRhs
  }
}

extension Plan where Self: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
}

/// Characteristics of a desired outcome, consisting of an obligatory, non-empty ``Headlined/title``
/// and an initially-empty set of ``toDos`` (referred to as "tasks" to the user). It intends to make
/// specific an otherwise broad objective, e.g., "work at Apple", by dividing it into various
/// intentional, trackable, time-constrained steps.
public protocol Goal: Headlined {
  /// Type of the ``ToDo``s by which this ``Goal`` is composed.
  associatedtype ToDoType: ToDo

  /// ``ToDo``s related to the achievement of the defined objective, sorted ascendingly by their
  /// ``ToDo/deadline`` and ``Headlined/title``.
  ///
  /// ###### Implementation notes
  ///
  /// The ``ToDo``s *must* be sorted and, even though this is an array, each of them *must* be
  /// unique, at least with an ID distinct from that of the other ones. Such uniqueness *must* be
  /// ensured by the public initializer or factory function.
  var toDos: [ToDoType] { get }

  /// Adds a ``ToDo`` to this ``Goal``.
  ///
  /// ###### Implementation notes
  ///
  /// The array returned by ``toDos`` *must* have been modified after a call to this function, with
  /// the ``ToDo`` included in it. By the time this function returns, such array *must* be sorted
  /// according to the criteria of comparison of the type of ``ToDo``.
  ///
  /// - Parameters:
  ///   - title: ``Headlined/title`` of the ``ToDo``.
  ///   - description: ``Headlined/description`` of the ``ToDo``.
  ///   - deadline: Date at which the ``ToDo`` is expected to be or have been done.
  /// - Returns: The added ``ToDo``.
  mutating func addToDo(
    titled title: String,
    describedAs description: String,
    due deadline: Date
  ) async -> ToDoType

  /// Removes the specified ``ToDo`` from this ``Goal``.
  ///
  /// ###### Implementation notes
  ///
  /// The array returned by ``toDos`` *must* have been modified after a call to this function, with
  /// the ``ToDo`` removed from it. By the time this function returns, such array *must* be sorted
  /// according to the criteria of comparison of the type of ``ToDo``.
  ///
  /// - Parameter id: ID of the ``ToDo`` to be removed.
  mutating func removeToDo(identifiedAs id: ToDoType.ID) async
}

extension Goal where Self: Comparable {
  public static func < (lhs: Self, rhs: Self) -> Bool {
    var isLhsLesserThanRhs = lhs.isLesser(than: rhs)
    if let firstLhsToDo = lhs.toDos.first, let firstRhsToDo = rhs.toDos.first {
      isLhsLesserThanRhs = isLhsLesserThanRhs && firstLhsToDo < firstRhsToDo
    }
    return isLhsLesserThanRhs
  }
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
public protocol ToDo: Headlined {
  /// Notes on the specifics of the achievement of this ``ToDo``, such as the prerequisites and
  /// prior preparations deemed necessary by the user. May also contain information about how it was
  /// done, detailing the process for mere posterior reading or as a basis for other plans.
  var description: String { get }

  /// Date at which this ``ToDo`` is expected to be or have been done.
  var deadline: Date { get }

  /// Whether this ``ToDo`` has been done.
  var isDone: Bool { get }

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
    lhs.isLesser(than: rhs) && lhs.deadline < rhs.deadline
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

public protocol Headlined: Comparable, Hashable, Identifiable {
  /// Main, general, non-blank description.
  var title: String { get }

  /// Secondary, detailed explanation related to the contents of the ``title``. May be blank.
  var description: String { get }

  /// Human-readable name for this type, included mid-sentence in the message printed before the
  /// execution of the program is interrupted in a playground or `-Onone` build when the title is
  /// empty upon normalization.
  ///
  /// - SeeAlso: ``normalize(_:_:)``
  static var description: String { get }

  /// Changes the ``Headlined/title``.
  ///
  /// - Parameter newTitle: Title by which the current one will be replaced.
  mutating func setTitle(to newTitle: String) async

  /// Changes the ``description``.
  ///
  /// - Parameter newDescription: Description by which the current one will be replaced.
  mutating func setDescription(to newDescription: String) async
}

extension Headlined where Self: Comparable {
  /// Compares the ``title`` and the ``description`` of both objects, allowing for them to be sorted
  /// alphabetically in an implementation of the ``<(_:_:)`` function. Should be called and have its
  /// return considered by every implementation of this type when a result of the latter function is
  /// given.
  ///
  /// - Parameter other: Right-hand-side of the comparison.
  func isLesser(than other: Self) -> Bool {
    title[title.startIndex] < other.title[other.title.startIndex]
      && description[description.startIndex] < other.description[other.description.startIndex]
  }
}
