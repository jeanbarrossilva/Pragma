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
                title: "Baseline fitness assessment",
                description: "Record weight, mobility, and strength baselines.",
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 60)
              ),
              .init(
                title: "Buy basic equipment",
                description: "Purchase mat, resistance bands, and dumbbells.",
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 50)
              ),
              .init(
                title: "Start strength training",
                description: "Begin a basic strength training routine three times per week.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 30)
              ),
              .init(
                title: "Create workout log",
                description: "Track exercises, loads, and reps.",
                status: .ongoing,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 10)
              ),
              .init(
                title: "Improve sleep schedule",
                description: "Maintain consistent sleep and wake times.",
                status: .ongoing,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 20)
              ),
              .init(
                title: "Schedule medical checkup",
                description: "Book and attend a general health checkup.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 14)
              ),
              .init(
                title: "Nutrition planning",
                description: "Draft a weekly balanced meal plan.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 18)
              ),
              .init(
                title: "Hydration habit",
                description: "Drink at least 2L of water daily.",
                status: .ongoing,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 7)
              ),
              .init(
                title: "Mobility routine",
                description: "Add 10 minutes of daily stretching.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 25)
              ),
              .init(
                title: "Cardio integration",
                description: "Include two weekly cardio sessions.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 35)
              ),
              .init(
                title: "Progress review",
                description: "Reassess metrics after eight weeks.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 56)
              )
            ]
          ),
          .init(
            title: "Improve mental focus",
            description: "Reduce distractions and improve concentration.",
            toDos: [
              .init(
                title: "Identify distractions",
                description: "List major sources of daily distraction.",
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 20)
              ),
              .init(
                title: "Daily meditation",
                description: "Meditate for at least ten minutes every morning.",
                status: .ongoing,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 21)
              ),
              .init(
                title: "Limit social media",
                description: "Reduce social media usage to less than thirty minutes per day.",
                status: .ongoing,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 10)
              ),
              .init(
                title: "Pomodoro practice",
                description: "Use focused 25-minute work intervals.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 14)
              ),
              .init(
                title: "Notification cleanup",
                description: "Disable non-essential notifications.",
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 15)
              ),
              .init(
                title: "Reading block",
                description: "Schedule a daily uninterrupted reading block.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 18)
              ),
              .init(
                title: "Mindfulness journaling",
                description: "Write short daily reflections.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 28)
              ),
              .init(
                title: "Digital detox day",
                description: "Spend one day per week offline.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 30)
              ),
              .init(
                title: "Focus metrics review",
                description: "Assess concentration improvements.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 45)
              ),
              .init(
                title: "Sustain routine",
                description: "Stabilize habits into a long-term routine.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 60)
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
                title: "Assess skill gaps",
                description: "Map current vs required skills.",
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 40)
              ),
              .init(
                title: "Study Swift concurrency",
                description: "Understand async/await, actors, and structured concurrency.",
                status: .ongoing,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 45)
              ),
              .init(
                title: "Concurrency exercises",
                description: "Solve small focused exercises.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 25)
              ),
              .init(
                title: "Read official proposals",
                description: "Review Swift Evolution concurrency proposals.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 30)
              ),
              .init(
                title: "Benchmark understanding",
                description: "Measure performance implications.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 35)
              ),
              .init(
                title: "Build sample project",
                description: "Create a small application applying new concurrency concepts.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 60)
              ),
              .init(
                title: "Code review session",
                description: "Review concurrency code with peers.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 55)
              ),
              .init(
                title: "Refactor legacy code",
                description: "Apply concurrency improvements to existing code.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 70)
              ),
              .init(
                title: "Document learnings",
                description: "Write internal documentation.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 75)
              ),
              .init(
                title: "Skill validation",
                description: "Validate mastery through delivery.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 90)
              )
            ]
          ),
          .init(
            title: "Improve communication",
            description: "Enhance written and verbal communication skills.",
            toDos: [
              .init(
                title: "Communication audit",
                description: "Identify weaknesses and strengths.",
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 25)
              ),
              .init(
                title: "Write technical articles",
                description: "Publish at least two technical articles.",
                status: .ongoing,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 40)
              ),
              .init(
                title: "Peer feedback",
                description: "Collect feedback on writing clarity.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 20)
              ),
              .init(
                title: "Public speaking practice",
                description: "Practice short technical talks.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 35)
              ),
              .init(
                title: "Presentation refinement",
                description: "Improve slide design and flow.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 45)
              ),
              .init(
                title: "Storytelling study",
                description: "Study narrative techniques.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 50)
              ),
              .init(
                title: "Publish second article",
                description: "Release a more advanced article.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 60)
              ),
              .init(
                title: "Conference proposal",
                description: "Submit a talk proposal.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 75)
              ),
              .init(
                title: "Live presentation",
                description: "Deliver a talk to an audience.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 90)
              ),
              .init(
                title: "Retrospective",
                description: "Evaluate communication growth.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 100)
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
            description: "Have someone capable of teaching singing skills.",
            toDos: [
              .init(
                title: "Define vocal goals",
                description: "Clarify singing objectives.",
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 25)
              ),
              .init(
                title: "Research coaches",
                description: "List qualified vocal coaches.",
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 18)
              ),
              .init(
                title: "Check availability",
                description: "Confirm schedules.",
                status: .ongoing,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 8)
              ),
              .init(
                title: "Trial lesson",
                description: "Attend a sample lesson.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 12)
              ),
              .init(
                title: "Budget confirmation",
                description: "Confirm pricing.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 14)
              ),
              .init(
                title: "Hire coach",
                description: "Formalize agreement.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 16)
              ),
              .init(
                title: "Warm-up routine",
                description: "Learn daily vocal warm-ups.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 20)
              ),
              .init(
                title: "Breathing exercises",
                description: "Practice diaphragmatic breathing.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 25)
              ),
              .init(
                title: "Song repertoire",
                description: "Select initial songs.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 35)
              ),
              .init(
                title: "Progress review",
                description: "Evaluate vocal improvement.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 55)
              )
            ]
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
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 10)
              ),
              .init(
                title: "Categorize expenses",
                description: "Group expenses into categories.",
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 7)
              ),
              .init(
                title: "Review subscriptions",
                description: "Cancel unnecessary subscriptions.",
                status: .ongoing,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 5)
              ),
              .init(
                title: "Income verification",
                description: "Confirm monthly income streams.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 3)
              ),
              .init(
                title: "Budget draft",
                description: "Create first budget version.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 6)
              ),
              .init(
                title: "Adjust allocations",
                description: "Refine category limits.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 10)
              ),
              .init(
                title: "Tool selection",
                description: "Choose budgeting tool.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 12)
              ),
              .init(
                title: "Monthly tracking",
                description: "Track spending weekly.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 30)
              ),
              .init(
                title: "Variance analysis",
                description: "Analyze budget deviations.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 35)
              ),
              .init(
                title: "Budget stabilization",
                description: "Stabilize budget over three months.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 90)
              )
            ]
          ),
          .init(
            title: "Emergency fund",
            description: "Build a financial safety net.",
            toDos: [
              .init(
                title: "Define target amount",
                description: "Set emergency fund goal.",
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 15)
              ),
              .init(
                title: "Open savings account",
                description: "Open a dedicated account for emergency savings.",
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 3)
              ),
              .init(
                title: "Set monthly contribution",
                description: "Define and automate monthly deposits.",
                status: .ongoing,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 20)
              ),
              .init(
                title: "Automate transfers",
                description: "Enable automatic transfers.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 5)
              ),
              .init(
                title: "First milestone",
                description: "Reach one-month expenses.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 30)
              ),
              .init(
                title: "Second milestone",
                description: "Reach three-month expenses.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 90)
              ),
              .init(
                title: "Liquidity review",
                description: "Confirm easy access to funds.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 95)
              ),
              .init(
                title: "Risk assessment",
                description: "Assess financial risks.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 100)
              ),
              .init(
                title: "Contribution adjustment",
                description: "Increase monthly deposits.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 120)
              ),
              .init(
                title: "Fund stabilization",
                description: "Maintain fund long-term.",
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 180)
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

  public static let description = "plan"

  fileprivate init(title: String, description: String, goals: [DemoGoal] = []) {
    var title = title
    var description = description
    Self.normalize(&title, &description)
    self.title = title
    self.description = description
    self.goals = goals
  }

  public mutating func setTitle(to newTitle: String) async {
    var newTitle = newTitle
    Self.normalize(&newTitle, &description)
    title = newTitle
  }

  public mutating func setDescription(to newDescription: String) async {
    var newDescription = newDescription
    Self.normalize(&title, &newDescription)
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

  public static let description = "goal"

  fileprivate init(title: String, description: String, toDos: [DemoToDo] = []) {
    var title = title
    var description = description
    Self.normalize(&title, &description)
    self.title = title
    self.description = description
    self.toDos = toDos
  }

  public mutating func setTitle(to newTitle: String) async {
    var newTitle = newTitle
    Self.normalize(&newTitle, &description)
    title = newTitle
  }

  public mutating func setDescription(to newDescription: String) async {
    var newDescription = newDescription
    Self.normalize(&title, &newDescription)
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
  public let id = UUID()
  public private(set) var title: String
  public private(set) var description: String
  public private(set) var status: Status
  public private(set) var deadline: Date

  public static let description = "to-do"

  fileprivate init(title: String, description: String, status: Status = .idle, deadline: Date) {
    var title = title
    var description = description
    Self.normalize(&title, &description)
    self.title = title
    self.description = description
    self.status = status
    self.deadline = deadline
  }

  public mutating func setTitle(to newTitle: String) async {
    var newTitle = newTitle
    Self.normalize(&newTitle, &description)
    title = newTitle
  }

  public mutating func setDescription(to newDescription: String) async {
    var newDescription = newDescription
    Self.normalize(&title, &newDescription)
    description = newDescription
  }

  public mutating func setStatus(to newStatus: Status) async { status = newStatus }
  public mutating func setDeadline(to newDeadline: Date) async { deadline = newDeadline }
}
