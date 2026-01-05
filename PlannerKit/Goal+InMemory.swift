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

import Foundation

/// ``Goal`` whose modifications and those on its ``InMemoryToDo``s are performed in-memory,
/// maintained only for as long as the program is being executed, with changes on these structs
/// being discarded upon their deinitialization.
public struct InMemoryGoal: Goal {
  public let id = UUID()
  public private(set) var title: String
  public private(set) var description: String
  public private(set) var toDos = [InMemoryToDo]()

  public init(title: String, description: String) {
    var title = title
    var description = description
    normalize(&title, &description, typeDescription: "goal")
    self.title = title
    self.description = description
  }

  public mutating func setTitle(to newTitle: String) async { title = newTitle }

  public mutating func setDescription(to newDescription: String) async {
    description = newDescription
  }

  public mutating func addToDo(
    titled title: String,
    describedAs description: String,
    due deadline: Date
  ) async -> UUID {
    let toDo = InMemoryToDo(title: title, description: description, deadline: deadline)
    toDos.append(toDo)
    return toDo.id
  }

  public mutating func removeToDo(identifiedAs id: UUID) async {
    guard let index = toDos.firstIndex(where: { toDo in toDo.id == id }) else { return }
    toDos.remove(at: index)
  }
}

/// ``ToDo`` of an ``InMemoryGoal`` whose modifications are performed in-memory, maintained for as
/// long as the program is being executed and discarted upon the deinitialization of this struct.
public struct InMemoryToDo: ToDo {
  public let id: UUID
  public private(set) var title: String
  public private(set) var description: String
  public private(set) var deadline: Date
  public private(set) var isDone: Bool = false

  public init(title: String, description: String, deadline: Date) {
    self = .init(id: .init(), title: title, description: description, deadline: deadline)
  }

  init(id: UUID, title: String, description: String, deadline: Date) {
    self.id = id
    var title = title
    var description = description
    normalize(&title, &description, typeDescription: "to-do")
    self.title = title
    self.description = description
    self.deadline = deadline
  }

  public mutating func setTitle(to newTitle: String) async { title = newTitle }

  public mutating func setDescription(to newDescription: String) async {
    description = newDescription
  }

  public mutating func setDeadline(to newDeadline: Date) async { deadline = newDeadline }
  public mutating func toggle() async { isDone.toggle() }
}
