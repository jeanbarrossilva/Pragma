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

extension AnyToDoDescriptor {
  /// Sample descriptors of to-dos for demonstration purposes.
  public static var samples: [Self] {
    AnyPlanDescriptor.samples.flatMap { plan in plan.goals.flatMap(\.toDos) }
  }
}

extension AnyGoalDescriptor {
  /// Sample descriptors of goals for demonstration purposes.
  public static var samples: [Self] { AnyPlanDescriptor.samples.flatMap(\.goals) }
}

extension AnyPlanDescriptor {
  /// Sample descriptors of plans for demonstration purposes.
  public static var samples: [Self] {
    [
      .init(
        title: "Personal development",
        abstract: "Long-term personal growth plan.",
        goals: [
          .init(
            title: "Improve physical health",
            abstract: "Build sustainable habits for physical well-being.",
            toDos: [
              .init(
                title: "Baseline fitness assessment",
                abstract: "Record weight, mobility, and strength baselines.",
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 60)
              ),
              .init(
                title: "Buy basic equipment",
                abstract: "Purchase mat, resistance bands, and dumbbells.",
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 50)
              ),
              .init(
                title: "Start strength training",
                abstract: "Begin a basic strength training routine three times per week.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 30)
              ),
              .init(
                title: "Create workout log",
                abstract: "Track exercises, loads, and reps.",
                status: .ongoing,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 10)
              ),
              .init(
                title: "Improve sleep schedule",
                abstract: "Maintain consistent sleep and wake times.",
                status: .ongoing,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 20)
              ),
              .init(
                title: "Schedule medical checkup",
                abstract: "Book and attend a general health checkup.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 14)
              ),
              .init(
                title: "Nutrition planning",
                abstract: "Draft a weekly balanced meal plan.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 18)
              ),
              .init(
                title: "Hydration habit",
                abstract: "Drink at least 2L of water daily.",
                status: .ongoing,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 7)
              ),
              .init(
                title: "Mobility routine",
                abstract: "Add 10 minutes of daily stretching.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 25)
              ),
              .init(
                title: "Cardio integration",
                abstract: "Include two weekly cardio sessions.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 35)
              ),
              .init(
                title: "Progress review",
                abstract: "Reassess metrics after eight weeks.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 56)
              )
            ]
          ),
          .init(
            title: "Improve mental focus",
            abstract: "Reduce distractions and improve concentration.",
            toDos: [
              .init(
                title: "Identify distractions",
                abstract: "List major sources of daily distraction.",
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 20)
              ),
              .init(
                title: "Daily meditation",
                abstract: "Meditate for at least ten minutes every morning.",
                status: .ongoing,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 21)
              ),
              .init(
                title: "Limit social media",
                abstract: "Reduce social media usage to less than thirty minutes per day.",
                status: .ongoing,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 10)
              ),
              .init(
                title: "Pomodoro practice",
                abstract: "Use focused 25-minute work intervals.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 14)
              ),
              .init(
                title: "Notification cleanup",
                abstract: "Disable non-essential notifications.",
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 15)
              ),
              .init(
                title: "Reading block",
                abstract: "Schedule a daily uninterrupted reading block.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 18)
              ),
              .init(
                title: "Mindfulness journaling",
                abstract: "Write short daily reflections.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 28)
              ),
              .init(
                title: "Digital detox day",
                abstract: "Spend one day per week offline.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 30)
              ),
              .init(
                title: "Focus metrics review",
                abstract: "Assess concentration improvements.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 45)
              ),
              .init(
                title: "Sustain routine",
                abstract: "Stabilize habits into a long-term routine.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 60)
              )
            ]
          )
        ]
      ),

      .init(
        title: "Career advancement",
        abstract: "Professional growth and skill acquisition.",
        goals: [
          .init(
            title: "Advance technical skills",
            abstract: "Deepen knowledge in core technical areas.",
            toDos: [
              .init(
                title: "Assess skill gaps",
                abstract: "Map current vs required skills.",
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 40)
              ),
              .init(
                title: "Study Swift concurrency",
                abstract: "Understand async/await, actors, and structured concurrency.",
                status: .ongoing,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 45)
              ),
              .init(
                title: "Concurrency exercises",
                abstract: "Solve small focused exercises.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 25)
              ),
              .init(
                title: "Read official proposals",
                abstract: "Review Swift Evolution concurrency proposals.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 30)
              ),
              .init(
                title: "Benchmark understanding",
                abstract: "Measure performance implications.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 35)
              ),
              .init(
                title: "Build sample project",
                abstract: "Create a small application applying new concurrency concepts.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 60)
              ),
              .init(
                title: "Code review session",
                abstract: "Review concurrency code with peers.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 55)
              ),
              .init(
                title: "Refactor legacy code",
                abstract: "Apply concurrency improvements to existing code.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 70)
              ),
              .init(
                title: "Document learnings",
                abstract: "Write internal documentation.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 75)
              ),
              .init(
                title: "Skill validation",
                abstract: "Validate mastery through delivery.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 90)
              )
            ]
          ),
          .init(
            title: "Improve communication",
            abstract: "Enhance written and verbal communication skills.",
            toDos: [
              .init(
                title: "Communication audit",
                abstract: "Identify weaknesses and strengths.",
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 25)
              ),
              .init(
                title: "Write technical articles",
                abstract: "Publish at least two technical articles.",
                status: .ongoing,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 40)
              ),
              .init(
                title: "Peer feedback",
                abstract: "Collect feedback on writing clarity.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 20)
              ),
              .init(
                title: "Public speaking practice",
                abstract: "Practice short technical talks.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 35)
              ),
              .init(
                title: "Presentation refinement",
                abstract: "Improve slide design and flow.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 45)
              ),
              .init(
                title: "Storytelling study",
                abstract: "Study narrative techniques.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 50)
              ),
              .init(
                title: "Publish second article",
                abstract: "Release a more advanced article.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 60)
              ),
              .init(
                title: "Conference proposal",
                abstract: "Submit a talk proposal.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 75)
              ),
              .init(
                title: "Live presentation",
                abstract: "Deliver a talk to an audience.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 90)
              ),
              .init(
                title: "Retrospective",
                abstract: "Evaluate communication growth.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 100)
              )
            ]
          )
        ]
      ),
      .init(
        title: "Artistic endeavours",
        abstract:
          "Make singing and dancing a part of the weekly schedule, taking lessons with professional teachers and vocal coaches.",
        goals: [
          .init(
            title: "Find a ballet school",
            abstract: "Catalog and decide on the school in which I will learn dancing."
          ),
          .init(
            title: "Hire a vocal coach",
            abstract: "Have someone capable of teaching singing skills.",
            toDos: [
              .init(
                title: "Define vocal goals",
                abstract: "Clarify singing objectives.",
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 25)
              ),
              .init(
                title: "Research coaches",
                abstract: "List qualified vocal coaches.",
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 18)
              ),
              .init(
                title: "Check availability",
                abstract: "Confirm schedules.",
                status: .ongoing,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 8)
              ),
              .init(
                title: "Trial lesson",
                abstract: "Attend a sample lesson.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 12)
              ),
              .init(
                title: "Budget confirmation",
                abstract: "Confirm pricing.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 14)
              ),
              .init(
                title: "Hire coach",
                abstract: "Formalize agreement.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 16)
              ),
              .init(
                title: "Warm-up routine",
                abstract: "Learn daily vocal warm-ups.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 20)
              ),
              .init(
                title: "Breathing exercises",
                abstract: "Practice diaphragmatic breathing.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 25)
              ),
              .init(
                title: "Song repertoire",
                abstract: "Select initial songs.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 35)
              ),
              .init(
                title: "Progress review",
                abstract: "Evaluate vocal improvement.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 55)
              )
            ]
          )
        ]
      ),

      .init(
        title: "Financial organization",
        abstract: "Gain clarity and control over personal finances.",
        goals: [
          .init(
            title: "Budgeting",
            abstract: "Create and maintain a monthly budget.",
            toDos: [
              .init(
                title: "List monthly expenses",
                abstract: "Document all recurring and variable expenses.",
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 10)
              ),
              .init(
                title: "Categorize expenses",
                abstract: "Group expenses into categories.",
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 7)
              ),
              .init(
                title: "Review subscriptions",
                abstract: "Cancel unnecessary subscriptions.",
                status: .ongoing,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 5)
              ),
              .init(
                title: "Income verification",
                abstract: "Confirm monthly income streams.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 3)
              ),
              .init(
                title: "Budget draft",
                abstract: "Create first budget version.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 6)
              ),
              .init(
                title: "Adjust allocations",
                abstract: "Refine category limits.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 10)
              ),
              .init(
                title: "Tool selection",
                abstract: "Choose budgeting tool.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 12)
              ),
              .init(
                title: "Monthly tracking",
                abstract: "Track spending weekly.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 30)
              ),
              .init(
                title: "Variance analysis",
                abstract: "Analyze budget deviations.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 35)
              ),
              .init(
                title: "Budget stabilization",
                abstract: "Stabilize budget over three months.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 90)
              )
            ]
          ),
          .init(
            title: "Emergency fund",
            abstract: "Build a financial safety net.",
            toDos: [
              .init(
                title: "Define target amount",
                abstract: "Set emergency fund goal.",
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 15)
              ),
              .init(
                title: "Open savings account",
                abstract: "Open a dedicated account for emergency savings.",
                status: .done,
                deadline: .init(timeIntervalSinceNow: -60 * 60 * 24 * 3)
              ),
              .init(
                title: "Set monthly contribution",
                abstract: "Define and automate monthly deposits.",
                status: .ongoing,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 20)
              ),
              .init(
                title: "Automate transfers",
                abstract: "Enable automatic transfers.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 5)
              ),
              .init(
                title: "First milestone",
                abstract: "Reach one-month expenses.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 30)
              ),
              .init(
                title: "Second milestone",
                abstract: "Reach three-month expenses.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 90)
              ),
              .init(
                title: "Liquidity review",
                abstract: "Confirm easy access to funds.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 95)
              ),
              .init(
                title: "Risk assessment",
                abstract: "Assess financial risks.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 100)
              ),
              .init(
                title: "Contribution adjustment",
                abstract: "Increase monthly deposits.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 120)
              ),
              .init(
                title: "Fund stabilization",
                abstract: "Maintain fund long-term.",
                status: .idle,
                deadline: .init(timeIntervalSinceNow: 60 * 60 * 24 * 180)
              )
            ]
          )
        ]
      ),
      .init(
        title: "Help LGBTQIAPN+ community",
        abstract: "Volunteer in some non-profitable organization."
      )
    ]
    .sorted()
  }
}
