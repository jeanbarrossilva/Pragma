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

import Planner
import SwiftUI

#Preview {
  GoalsList(goals: [
    InMemoryGoal(
      title: "Work at Apple",
      description: "Be employed by one the most influential tech companies in the world."
    ),
    .init(
      title: "Simulate the Big Bang",
      description: "Develop a computer simulation for the origin of the Universe emergently.",
      toDos: [
        .init(
          title: "Know kindergarden-level mathematics",
          description: "",
          deadline: .distantFuture
        ), .init(title: "Study the basics of physics", description: "", deadline: .distantFuture)
      ]
    )
  ])
}

struct GoalsList<GoalType>: View where GoalType: Goal {
  var body: some View {
    NavigationSplitView {
      List { ForEach((2014...2026).reversed(), id: \.self) { plan in Text(plan.description) } }
    } detail: {
      ScrollView {
        LazyVStack(alignment: .leading, spacing: 32) {
          ForEach(Array(zip(goals.indices, goals)), id: \.1.id) { (index, goal) in
            GoalBoard(goal: goal).padding(.horizontal, 32).padding(
              .top,
              index == goals.startIndex ? 32 : 0
            ).padding(.bottom, index == goals.index(before: goals.endIndex) ? 32 : 0)
          }
        }
      }
    }
  }

  private let goals: [GoalType]

  @State
  private var selectedPlanIndex = 0

  init(goals: [GoalType]) { self.goals = goals }
}
