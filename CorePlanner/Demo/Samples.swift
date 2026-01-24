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

extension ReadOnlyToDo {
  /// Sample to-dos for demonstration purposes.
  public static var samples: [Self] {
    ReadOnlyPlan.samples.flatMap { plan in plan.goals.flatMap(\.toDos) }
  }
}

extension ReadOnlyGoal {
  /// Sample goals for demonstration purposes.
  public static var samples: [Self] { ReadOnlyPlan.samples.flatMap(\.goals) }
}

extension ReadOnlyPlan {
  /// Sample plans for demonstration purposes.
  public static var samples: [Self] {
    [
      .init(
        id: .init(UUID()),
        title: "Personal development",
        summary: "Long-term personal growth plan.",
        goals: [
          .init(
            id: .init(UUID()),
            title: "Improve physical health",
            summary: "Build sustainable habits for physical well-being.",
            toDos: [
              .init(
                id: .init(UUID()),
                title: "Baseline fitness assessment",
                summary: "Record weight, mobility, and strength baselines.",
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 60)
              ),
              .init(
                id: .init(UUID()),
                title: "Buy basic equipment",
                summary: "Purchase mat, resistance bands, and dumbbells.",
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 50)
              ),
              .init(
                id: .init(UUID()),
                title: "Start strength training",
                summary: "Begin a basic strength training routine three times per week.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 30)
              ),
              .init(
                id: .init(UUID()),
                title: "Create workout log",
                summary: "Track exercises, loads, and reps.",
                status: .ongoing,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 10)
              ),
              .init(
                id: .init(UUID()),
                title: "Improve sleep schedule",
                summary: "Maintain consistent sleep and wake times.",
                status: .ongoing,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 20)
              ),
              .init(
                id: .init(UUID()),
                title: "Schedule medical checkup",
                summary: "Book and attend a general health checkup.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 14)
              ),
              .init(
                id: .init(UUID()),
                title: "Nutrition planning",
                summary: "Draft a weekly balanced meal plan.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 18)
              ),
              .init(
                id: .init(UUID()),
                title: "Hydration habit",
                summary: "Drink at least 2L of water daily.",
                status: .ongoing,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 7)
              ),
              .init(
                id: .init(UUID()),
                title: "Mobility routine",
                summary: "Add 10 minutes of daily stretching.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 25)
              ),
              .init(
                id: .init(UUID()),
                title: "Cardio integration",
                summary: "Include two weekly cardio sessions.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 35)
              ),
              .init(
                id: .init(UUID()),
                title: "Progress review",
                summary: "Reassess metrics after eight weeks.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 56)
              )
            ]
          ),
          .init(
            id: .init(UUID()),
            title: "Improve mental focus",
            summary: "Reduce distractions and improve concentration.",
            toDos: [
              .init(
                id: .init(UUID()),
                title: "Identify distractions",
                summary: "List major sources of daily distraction.",
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 20)
              ),
              .init(
                id: .init(UUID()),
                title: "Daily meditation",
                summary: "Meditate for at least ten minutes every morning.",
                status: .ongoing,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 21)
              ),
              .init(
                id: .init(UUID()),
                title: "Limit social media",
                summary: "Reduce social media usage to less than thirty minutes per day.",
                status: .ongoing,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 10)
              ),
              .init(
                id: .init(UUID()),
                title: "Pomodoro practice",
                summary: "Use focused 25-minute work intervals.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 14)
              ),
              .init(
                id: .init(UUID()),
                title: "Notification cleanup",
                summary: "Disable non-essential notifications.",
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 15)
              ),
              .init(
                id: .init(UUID()),
                title: "Reading block",
                summary: "Schedule a daily uninterrupted reading block.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 18)
              ),
              .init(
                id: .init(UUID()),
                title: "Mindfulness journaling",
                summary: "Write short daily reflections.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 28)
              ),
              .init(
                id: .init(UUID()),
                title: "Digital detox day",
                summary: "Spend one day per week offline.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 30)
              ),
              .init(
                id: .init(UUID()),
                title: "Focus metrics review",
                summary: "Assess concentration improvements.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 45)
              ),
              .init(
                id: .init(UUID()),
                title: "Sustain routine",
                summary: "Stabilize habits into a long-term routine.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 60)
              )
            ]
          )
        ]
      ),

      .init(
        id: .init(UUID()),
        title: "Career advancement",
        summary: "Professional growth and skill acquisition.",
        goals: [
          .init(
            id: .init(UUID()),
            title: "Advance technical skills",
            summary: "Deepen knowledge in core technical areas.",
            toDos: [
              .init(
                id: .init(UUID()),
                title: "Assess skill gaps",
                summary: "Map current vs required skills.",
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 40)
              ),
              .init(
                id: .init(UUID()),
                title: "Study Swift concurrency",
                summary: "Understand async/await, actors, and structured concurrency.",
                status: .ongoing,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 45)
              ),
              .init(
                id: .init(UUID()),
                title: "Concurrency exercises",
                summary: "Solve small focused exercises.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 25)
              ),
              .init(
                id: .init(UUID()),
                title: "Read official proposals",
                summary: "Review Swift Evolution concurrency proposals.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 30)
              ),
              .init(
                id: .init(UUID()),
                title: "Benchmark understanding",
                summary: "Measure performance implications.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 35)
              ),
              .init(
                id: .init(UUID()),
                title: "Build sample project",
                summary: "Create a small application applying new concurrency concepts.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 60)
              ),
              .init(
                id: .init(UUID()),
                title: "Code review session",
                summary: "Review concurrency code with peers.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 55)
              ),
              .init(
                id: .init(UUID()),
                title: "Refactor legacy code",
                summary: "Apply concurrency improvements to existing code.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 70)
              ),
              .init(
                id: .init(UUID()),
                title: "Document learnings",
                summary: "Write internal documentation.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 75)
              ),
              .init(
                id: .init(UUID()),
                title: "Skill validation",
                summary: "Validate mastery through delivery.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 90)
              )
            ]
          ),
          .init(
            id: .init(UUID()),
            title: "Improve communication",
            summary: "Enhance written and verbal communication skills.",
            toDos: [
              .init(
                id: .init(UUID()),
                title: "Communication audit",
                summary: "Identify weaknesses and strengths.",
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 25)
              ),
              .init(
                id: .init(UUID()),
                title: "Write technical articles",
                summary: "Publish at least two technical articles.",
                status: .ongoing,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 40)
              ),
              .init(
                id: .init(UUID()),
                title: "Peer feedback",
                summary: "Collect feedback on writing clarity.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 20)
              ),
              .init(
                id: .init(UUID()),
                title: "Public speaking practice",
                summary: "Practice short technical talks.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 35)
              ),
              .init(
                id: .init(UUID()),
                title: "Presentation refinement",
                summary: "Improve slide design and flow.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 45)
              ),
              .init(
                id: .init(UUID()),
                title: "Storytelling study",
                summary: "Study narrative techniques.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 50)
              ),
              .init(
                id: .init(UUID()),
                title: "Publish second article",
                summary: "Release a more advanced article.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 60)
              ),
              .init(
                id: .init(UUID()),
                title: "Conference proposal",
                summary: "Submit a talk proposal.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 75)
              ),
              .init(
                id: .init(UUID()),
                title: "Live presentation",
                summary: "Deliver a talk to an audience.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 90)
              ),
              .init(
                id: .init(UUID()),
                title: "Retrospective",
                summary: "Evaluate communication growth.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 100)
              )
            ]
          )
        ]
      ),

      .init(
        id: .init(UUID()),
        title: "Artistic endeavours",
        summary:
          "Make singing and dancing a part of the weekly schedule, taking lessons with professional teachers and vocal coaches.",
        goals: [
          .init(
            id: .init(UUID()),
            title: "Find a ballet school",
            summary: "Catalog and decide on the school in which I will learn dancing.",
            toDos: []
          ),
          .init(
            id: .init(UUID()),
            title: "Hire a vocal coach",
            summary: "Have someone capable of teaching singing skills.",
            toDos: [
              .init(
                id: .init(UUID()),
                title: "Define vocal goals",
                summary: "Clarify singing objectives.",
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 25)
              ),
              .init(
                id: .init(UUID()),
                title: "Research coaches",
                summary: "List qualified vocal coaches.",
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 18)
              ),
              .init(
                id: .init(UUID()),
                title: "Check availability",
                summary: "Confirm schedules.",
                status: .ongoing,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 8)
              ),
              .init(
                id: .init(UUID()),
                title: "Trial lesson",
                summary: "Attend a sample lesson.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 12)
              ),
              .init(
                id: .init(UUID()),
                title: "Budget confirmation",
                summary: "Confirm pricing.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 14)
              ),
              .init(
                id: .init(UUID()),
                title: "Hire coach",
                summary: "Formalize agreement.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 16)
              ),
              .init(
                id: .init(UUID()),
                title: "Warm-up routine",
                summary: "Learn daily vocal warm-ups.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 20)
              ),
              .init(
                id: .init(UUID()),
                title: "Breathing exercises",
                summary: "Practice diaphragmatic breathing.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 25)
              ),
              .init(
                id: .init(UUID()),
                title: "Song repertoire",
                summary: "Select initial songs.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 35)
              ),
              .init(
                id: .init(UUID()),
                title: "Progress review",
                summary: "Evaluate vocal improvement.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 55)
              )
            ]
          )
        ]
      ),

      .init(
        id: .init(UUID()),
        title: "Financial organization",
        summary: "Gain clarity and control over personal finances.",
        goals: [
          .init(
            id: .init(UUID()),
            title: "Budgeting",
            summary: "Create and maintain a monthly budget.",
            toDos: [
              .init(
                id: .init(UUID()),
                title: "List monthly expenses",
                summary: "Document all recurring and variable expenses.",
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 10)
              ),
              .init(
                id: .init(UUID()),
                title: "Categorize expenses",
                summary: "Group expenses into categories.",
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 7)
              ),
              .init(
                id: .init(UUID()),
                title: "Review subscriptions",
                summary: "Cancel unnecessary subscriptions.",
                status: .ongoing,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 5)
              ),
              .init(
                id: .init(UUID()),
                title: "Income verification",
                summary: "Confirm monthly income streams.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 3)
              ),
              .init(
                id: .init(UUID()),
                title: "Budget draft",
                summary: "Create first budget version.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 6)
              ),
              .init(
                id: .init(UUID()),
                title: "Adjust allocations",
                summary: "Refine category limits.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 10)
              ),
              .init(
                id: .init(UUID()),
                title: "Tool selection",
                summary: "Choose budgeting tool.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 12)
              ),
              .init(
                id: .init(UUID()),
                title: "Monthly tracking",
                summary: "Track spending weekly.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 30)
              ),
              .init(
                id: .init(UUID()),
                title: "Variance analysis",
                summary: "Analyze budget deviations.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 35)
              ),
              .init(
                id: .init(UUID()),
                title: "Budget stabilization",
                summary: "Stabilize budget over three months.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 90)
              )
            ]
          ),
          .init(
            id: .init(UUID()),
            title: "Emergency fund",
            summary: "Build a financial safety net.",
            toDos: [
              .init(
                id: .init(UUID()),
                title: "Define target amount",
                summary: "Set emergency fund goal.",
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 15)
              ),
              .init(
                id: .init(UUID()),
                title: "Open savings account",
                summary: "Open a dedicated account for emergency savings.",
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 3)
              ),
              .init(
                id: .init(UUID()),
                title: "Set monthly contribution",
                summary: "Define and automate monthly deposits.",
                status: .ongoing,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 20)
              ),
              .init(
                id: .init(UUID()),
                title: "Automate transfers",
                summary: "Enable automatic transfers.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 5)
              ),
              .init(
                id: .init(UUID()),
                title: "First milestone",
                summary: "Reach one-month expenses.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 30)
              ),
              .init(
                id: .init(UUID()),
                title: "Second milestone",
                summary: "Reach three-month expenses.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 90)
              ),
              .init(
                id: .init(UUID()),
                title: "Liquidity review",
                summary: "Confirm easy access to funds.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 95)
              ),
              .init(
                id: .init(UUID()),
                title: "Risk assessment",
                summary: "Assess financial risks.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 100)
              ),
              .init(
                id: .init(UUID()),
                title: "Contribution adjustment",
                summary: "Increase monthly deposits.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 120)
              ),
              .init(
                id: .init(UUID()),
                title: "Fund stabilization",
                summary: "Maintain fund long-term.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 180)
              )
            ]
          )
        ]
      ),
      .init(
        id: .init(UUID()),
        title: "Help LGBTQIAPN+ community",
        summary: "Volunteer in some non-profitable organization.",
        goals: []
      )
    ]
  }
}
