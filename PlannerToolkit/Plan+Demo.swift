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

/// Central static utility from which sample ``Planner``-related structures can be generated for
/// demonstration purposes, useful for populating a client of the API with pre-existing data for
/// previewing UI and overall behavior. Any changes to the generated structures are performed in
/// memory and are not persisted after their deinitialization.
public struct DemoPlanning {
  /// This is a static utility and, therefore, should not be initialized.
  private init() {}

  /// Sample goals for demonstration purposes.
  public static var goals: [DemoGoal] { plans.flatMap(\.goals) }

  /// Sample to-dos for demonstration purposes.
  public static var toDos: [DemoToDo] { plans.flatMap { plan in plan.goals.flatMap(\.toDos) } }

  /// Sample plans for demonstration purposes.
  public static var plans: [DemoPlan] {
    [
      .init(
        title: "Personal development",
        description: "Long-term personal growth plan.",
        goals: [
          .init(
            title: "Improve physical health",
            description: "Build sustainable habits for physical well-being.",
            toDos: [
              .init(
                title: "Start strength training",
                description: "Begin a basic strength training routine three times per week.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 30)
              ),
              .init(
                title: "Schedule medical checkup",
                description: "Book and attend a general health checkup.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 14)
              )
            ]
          ),
          .init(
            title: "Improve mental focus",
            description: "Reduce distractions and improve concentration.",
            toDos: [
              .init(
                title: "Daily meditation",
                description: "Meditate for at least ten minutes every morning.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 21)
              ),
              .init(
                title: "Limit social media",
                description: "Reduce social media usage to less than thirty minutes per day.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 10)
              )
            ]
          )
        ]
      ),
      .init(
        title: "Career advancement",
        description: "Professional growth and skill acquisition.",
        goals: [
          .init(
            title: "Advance technical skills",
            description: "Deepen knowledge in core technical areas.",
            toDos: [
              .init(
                title: "Study Swift concurrency",
                description: "Understand async/await, actors, and structured concurrency.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 45)
              ),
              .init(
                title: "Build sample project",
                description: "Create a small application applying new concurrency concepts.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 60)
              )
            ]
          ),
          .init(
            title: "Improve communication",
            description: "Enhance written and verbal communication skills.",
            toDos: [
              .init(
                title: "Write technical articles",
                description: "Publish at least two technical articles.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 40)
              )
            ]
          )
        ]
      ),
      .init(
        title: "Artistic endeavours",
        description: "Make singing and dancing a part of the weekly schedule, taking lessons with "
          + "professional teachers and vocal coaches.",
        goals: [
          .init(
            title: "Find a ballet school",
            description: "Catalog and decide on the school in which I will learn dancing."
          ),
          .init(
            title: "Hire a vocal coach",
            description: "Have someone capable of teaching singing skills."
          )
        ]
      ),
      .init(
        title: "Financial organization",
        description: "Gain clarity and control over personal finances.",
        goals: [
          .init(
            title: "Budgeting",
            description: "Create and maintain a monthly budget.",
            toDos: [
              .init(
                title: "List monthly expenses",
                description: "Document all recurring and variable expenses.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 7)
              ),
              .init(
                title: "Review subscriptions",
                description: "Cancel unnecessary subscriptions.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 5)
              )
            ]
          ),
          .init(
            title: "Emergency fund",
            description: "Build a financial safety net.",
            toDos: [
              .init(
                title: "Open savings account",
                description: "Open a dedicated account for emergency savings.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 3)
              ),
              .init(
                title: "Set monthly contribution",
                description: "Define and automate monthly deposits.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 20)
              )
            ]
          )
        ]
      )
    ]
  }
}

/// Plan whose modifications, including those on its goals and to-dos, are performed in-memory,
/// maintained only for as long as the program is being executed, with changes on these structs
/// being discarded upon their deinitialization.
public struct DemoPlan: Plan {
  public let id = UUID()
  public private(set) var title: String
  public private(set) var description: String
  public private(set) var goals: [DemoGoal]

  fileprivate init(title: String, description: String, goals: [DemoGoal] = []) {
    var title = title
    var description = description
    normalize(&title, &description, typeDescription: "plan")
    self.title = title
    self.description = description
    self.goals = goals
  }

  public mutating func setTitle(to newTitle: String) async { title = newTitle }

  public mutating func setDescription(to newDescription: String) async {
    description = newDescription
  }

  public mutating func addGoal(
    titled title: String,
    describedAs description: String
  ) async -> DemoGoal {
    let goal = DemoGoal(title: title, description: description)
    goals.append(goal)
    return goal
  }

  public mutating func removeGoal(identifiedAs id: UUID) async {
    guard let index = goals.firstIndex(where: { goal in goal.id == id }) else { return }
    goals.remove(at: index)
  }
}

/// Goal whose modifications and those on its to-dos are performed in-memory, maintained only for as
/// long as the program is being executed, with changes on these structs being discarded upon their
/// deinitialization.
public struct DemoGoal: Goal {
  public let id = UUID()
  public private(set) var title: String
  public private(set) var description: String
  public private(set) var toDos: [DemoToDo]

  fileprivate init(title: String, description: String, toDos: [DemoToDo] = []) {
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
  ) async -> DemoToDo {
    let toDo = DemoToDo(title: title, description: description, deadline: deadline)
    toDos.append(toDo)
    return toDo
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

  fileprivate init(title: String, description: String, deadline: Date) {
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
