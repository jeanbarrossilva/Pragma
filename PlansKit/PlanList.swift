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

#Preview("Without plans") { PlanList(plans: [DemoPlan](), onPlanAdditionRequest: {}) }
#Preview("With plans") { PlanList(plans: DemoPlanning.plans, onPlanAdditionRequest: {}) }

public struct PlanList<PlanType>: View where PlanType: Plan {
  public var body: some View {
    if plans.isEmpty {
      EmptyPlanList(onPlanAdditionRequest: onPlanAdditionRequest).padding()
    } else {
      PopulatedPlanList(plans: plans)
    }
  }

  private let plans: [PlanType]
  private let onPlanAdditionRequest: () -> Void

  public init(plans: [PlanType], onPlanAdditionRequest: @escaping () -> Void) {
    self.plans = plans
    self.onPlanAdditionRequest = onPlanAdditionRequest
  }
}

private struct EmptyPlanList: View {
  var body: some View {
    Callout {
      Button(action: onPlanAdditionRequest) { Image(systemName: "plus") }
    } title: {
      Text("No plans in sight… for now.")
    } description: {
      Text(
        "Think about the things you wish to achieve and, when done, click that \"+\" button on "
          + "the \(layoutDirection == .leftToRight ? "right" : "left")."
      )
    }
  }

  @Environment(\.layoutDirection)
  private var layoutDirection

  private let onPlanAdditionRequest: () -> Void

  init(onPlanAdditionRequest: @escaping () -> Void) {
    self.onPlanAdditionRequest = onPlanAdditionRequest
  }
}

private struct PopulatedPlanList<PlanType>: View where PlanType: Plan {
  var body: some View {
    GeometryReader { proxy in
      NavigationSplitView {
        List(plans) { plan in
          Button {
            selectedPlan = plan
          } label: {
            HStack {
              Text(plan.title).lineLimit(2).multilineTextAlignment(.leading)
              Spacer()
            }.padding(4)
          }.buttonStyle(
            plan != selectedPlan ? AnyPrimitiveButtonStyle(.plain) : .init(.borderedProminent)
          )
        }.navigationTitle("Plans").navigationSplitViewColumnWidth(
          min: proxy.size.width * 0.16,
          ideal: proxy.size.width * 0.16,
          max: proxy.size.width * 0.32
        )
      } detail: {
        ScrollView {
          LazyVStack(alignment: .leading, spacing: 32) {
            ForEach(Array(zip(selectedPlan.goals.indices, selectedPlan.goals)), id: \.1.id) {
              (index, goal) in
              GoalBoard(goal: goal, onToDoAdditionRequest: {}).padding(.horizontal, 32).padding(
                .top,
                index == selectedPlan.goals.startIndex ? 32 : 0
              ).padding(
                .bottom,
                index == selectedPlan.goals.index(before: selectedPlan.goals.endIndex) ? 32 : 0
              )
            }
          }
        }
      }
    }
  }

  private let plans: [PlanType]

  @State
  private var selectedPlan: PlanType

  init(plans: [PlanType]) {
    self.plans = plans
    self.selectedPlan = plans[0]
  }
}

private struct AnyPrimitiveButtonStyle: PrimitiveButtonStyle {
  let base: Any

  init(_ base: some PrimitiveButtonStyle) { self.base = base }

  func makeBody(configuration: Configuration) -> AnyView {
    AnyView((base as! any PrimitiveButtonStyle).makeBody(configuration: configuration))
  }
}
