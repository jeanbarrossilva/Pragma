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

/// Goal whose modifications and those on its to-dos are performed in-memory, maintained only for as
/// long as the program is being executed, with changes on these structs being discarded upon their
/// deinitialization.
public struct DemoGoal: Goal {
  public let id = UUID()
  public private(set) var title: String
  public private(set) var description: String
  public private(set) var toDos: [DemoToDo]

  public init(title: String, description: String, toDos: [DemoToDo] = []) {
    var title = title
    var description = description
    normalize(&title, &description, typeDescription: "goal")
    self.title = title
    self.description = description
    self.toDos = toDos
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
    let toDo = DemoToDo(title: title, description: description, deadline: deadline)
    toDos.append(toDo)
    return toDo.id
  }

  public mutating func removeToDo(identifiedAs id: UUID) async {
    guard let index = toDos.firstIndex(where: { toDo in toDo.id == id }) else { return }
    toDos.remove(at: index)
  }
}

/// To-do of a ``DemoGoal`` whose modifications are performed in-memory, maintained for as long as
/// the program is being executed and discarted upon the deinitialization of this struct.
public struct DemoToDo: ToDo {
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
