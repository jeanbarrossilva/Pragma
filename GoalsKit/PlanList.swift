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

import PlannerToolkit
import SwiftUI

#Preview { PlanList(plans: DemoPlanning.plans) }

struct PlanList<PlanType>: View where PlanType: Plan {
  var body: some View {
    GeometryReader { proxy in
      NavigationSplitView {
        List(plans) { plan in
          Button {
            selectedPlan = plan
          } label: {
            Text(plan.title).padding(4).lineLimit(2).multilineTextAlignment(.leading)
          }.buttonStyle(
            plan != selectedPlan ? AnyPrimitiveButtonStyle(.plain) : .init(.borderedProminent)
          )
        }.navigationTitle("Plans").navigationSplitViewColumnWidth(
          min: proxy.size.width * 0.24,
          ideal: proxy.size.width * 0.24,
          max: proxy.size.width * 0.32
        )
      } detail: {
        if let goals = selectedPlan?.goals {
          ScrollView {
            LazyVStack(alignment: .leading, spacing: 32) {
              ForEach(Array(zip(goals.indices, goals)), id: \.1.id) { (index, goal) in
                GoalBoard(goal: goal, onToDoAdditionRequest: {}).padding(.horizontal, 32).padding(
                  .top,
                  index == goals.startIndex ? 32 : 0
                ).padding(.bottom, index == goals.index(before: goals.endIndex) ? 32 : 0)
              }
            }
          }
        }
      }
    }
  }

  private let plans: [PlanType]

  @State
  private var selectedPlan: PlanType?

  init(plans: [PlanType]) {
    self.plans = plans
    self.selectedPlan = plans.first
  }
}

private struct AnyPrimitiveButtonStyle: PrimitiveButtonStyle {
  let base: Any

  init(_ base: some PrimitiveButtonStyle) { self.base = base }

  func makeBody(configuration: Configuration) -> AnyView {
    AnyView((base as! any PrimitiveButtonStyle).makeBody(configuration: configuration))
  }
}
