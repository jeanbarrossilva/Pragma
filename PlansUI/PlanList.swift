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

import PlannerKit
import PlannerUI
import SwiftUI

#Preview("Without plans") {
  PlanList(
    plans: [],
    onDidRequestPlanAddition: {},
    onDidRequestToDoAddition: { _ in },
    onDidRequestToDoTransfer: { _, _, _ in }
  )
}

#Preview("With plans") {
  PlanList(
    plans: ReadOnlyPlan.samples,
    onDidRequestPlanAddition: {},
    onDidRequestToDoAddition: { _ in },
    onDidRequestToDoTransfer: { _, _, _ in }
  )
}

public struct PlanList: View {
  public var body: some View {
    if plans.isEmpty {
      EmptyPlanList(onDidRequestPlanAddition: onDidRequestPlanAddition)
        .padding()
    } else {
      PopulatedPlanList(
        plans: plans,
        onDidRequestToDoAddition: onDidRequestToDoAddition,
        onDidRequestToDoTransfer: onDidRequestToDoTransfer
      )
    }
  }

  private let plans: [ReadOnlyPlan]
  private let onDidRequestPlanAddition: () -> Void
  private let onDidRequestToDoAddition: (ReadOnlyPlan) -> Void
  private let onDidRequestToDoTransfer:
    (_ destinationGoal: ReadOnlyGoal, _ transferredToDos: [ReadOnlyToDo], _ newStatus: Status) ->
      Void

  public init(
    plans: [ReadOnlyPlan],
    onDidRequestPlanAddition: @escaping () -> Void,
    onDidRequestToDoAddition: @escaping (ReadOnlyPlan) -> Void,
    onDidRequestToDoTransfer:
      @escaping (
        _ destinationGoal: ReadOnlyGoal, _ transferredToDos: [ReadOnlyToDo], _ newStatus: Status
      )
      -> Void
  ) {
    self.plans = plans
    self.onDidRequestPlanAddition = onDidRequestPlanAddition
    self.onDidRequestToDoAddition = onDidRequestToDoAddition
    self.onDidRequestToDoTransfer = onDidRequestToDoTransfer
  }
}

private struct EmptyPlanList: View {
  var body: some View {
    Callout {
      Button(action: onDidRequestPlanAddition) { Image(systemName: "plus") }
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

  private let onDidRequestPlanAddition: () -> Void

  init(onDidRequestPlanAddition: @escaping () -> Void) {
    self.onDidRequestPlanAddition = onDidRequestPlanAddition
  }
}

private struct PopulatedPlanList: View {
  var body: some View {
    GeometryReader { geometry in
      NavigationSplitView {
        List(plans) { plan in
          Button {
            selectedPlan = plan
          } label: {
            HStack {
              Text(plan.title).lineLimit(2).multilineTextAlignment(.leading)
              Spacer()
            }
            .padding(4)
          }
          .buttonStyle(
            plan != selectedPlan ? AnyPrimitiveButtonStyle(.plain) : .init(.borderedProminent)
          )
        }
        .navigationTitle("Plans")
        .navigationSplitViewColumnWidth(
          min: geometry.size.width * 0.16,
          ideal: geometry.size.width * 0.16,
          max: geometry.size.width * 0.32
        )
      } detail: {
        ScrollView {
          LazyVStack(alignment: .leading, spacing: 32) {
            ForEach(Array(zip(selectedPlan.goals.indices, selectedPlan.goals)), id: \.1.id) {
              (index, goal) in
              GoalBoard(
                goal: goal,
                onDidRequestToDoAddition: { onDidRequestToDoAddition(selectedPlan) },
                onDidRequestStatusChange: { toDos, newStatus in
                  onDidRequestToDoTransfer(goal, toDos, newStatus)
                }
              )
              .padding(.horizontal, 32)
              .padding(.top, index == selectedPlan.goals.startIndex ? 32 : 0)
              .padding(
                .bottom,
                index == selectedPlan.goals.index(before: selectedPlan.goals.endIndex) ? 32 : 0
              )
            }
          }
        }
      }
    }
  }

  private let plans: [ReadOnlyPlan]
  private let onDidRequestToDoAddition: (ReadOnlyPlan) -> Void
  private let onDidRequestToDoTransfer:
    (_ destinationGoal: ReadOnlyGoal, _ transferredToDos: [ReadOnlyToDo], _ newStatus: Status) ->
      Void

  @State
  private var selectedPlan: ReadOnlyPlan

  init(
    plans: [ReadOnlyPlan],
    onDidRequestToDoAddition: @escaping (ReadOnlyPlan) -> Void,
    onDidRequestToDoTransfer:
      @escaping (
        _ destinationGoal: ReadOnlyGoal, _ transferredToDos: [ReadOnlyToDo], _ newStatus: Status
      ) -> Void
  ) {
    self.plans = plans
    self.selectedPlan = plans[0]
    self.onDidRequestToDoAddition = onDidRequestToDoAddition
    self.onDidRequestToDoTransfer = onDidRequestToDoTransfer
  }
}

private struct AnyPrimitiveButtonStyle: PrimitiveButtonStyle {
  let base: Any

  init(_ base: some PrimitiveButtonStyle) { self.base = base }

  func makeBody(configuration: Configuration) -> AnyView {
    AnyView((base as! any PrimitiveButtonStyle).makeBody(configuration: configuration))
  }
}
