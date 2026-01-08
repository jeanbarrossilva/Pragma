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

#Preview("Without to-dos") {
  GoalBoard(goal: DemoPlanning.goals.first(where: \.toDos.isEmpty)!, onToDoAdditionRequest: {})
    .padding()
}

#Preview("With to-dos") {
  GoalBoard(
    goal: DemoPlanning.goals.first(where: { goal in !goal.toDos.isEmpty })!,
    onToDoAdditionRequest: {}
  ).padding().padding(.vertical, 8)
}

public struct GoalBoard<GoalType>: View where GoalType: Goal {
  public var body: some View {
    if goal.toDos.isEmpty {
      EmptyGoalBoard(goal: goal, onToDoAdditionRequest: onToDoAdditionRequest)
    } else {
      GroupBox {
        PopulatedGoalBoard(toDos: goal.toDos)
      } label: {
        Headline(goal: goal).padding(.bottom, 12)
      }
    }
  }

  private let goal: GoalType
  private let onToDoAdditionRequest: () -> Void

  init(goal: GoalType, onToDoAdditionRequest: @escaping () -> Void) {
    self.goal = goal
    self.onToDoAdditionRequest = onToDoAdditionRequest
  }
}

private struct EmptyGoalBoard<GoalType>: View where GoalType: Goal {
  var body: some View {
    VStack(alignment: .leading, spacing: 18) {
      Headline(goal: goal)
      Callout {
        Button(action: onToDoAdditionRequest) { ZStack { Image(systemName: "plus") } }
      } title: {
        Text("No to-dos yet!")
      } description: {
        Text("Think about the minimal steps you have to take in order to achieve this goal.")
      }
    }
  }

  private let goal: GoalType
  private let onToDoAdditionRequest: () -> Void

  init(goal: GoalType, onToDoAdditionRequest: @escaping () -> Void) {
    self.goal = goal
    self.onToDoAdditionRequest = onToDoAdditionRequest
  }
}

private struct Headline<GoalType>: View where GoalType: Goal {
  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(goal.title).font(.system(.title, weight: .heavy))
      Text(goal.description).font(.system(.headline, weight: .regular)).foregroundStyle(.secondary)
    }
  }

  private let goal: GoalType

  init(goal: GoalType) { self.goal = goal }
}

private struct PopulatedGoalBoard<ToDoType: ToDo>: View where ToDoType: ToDo {
  var body: some View {
    HStack(alignment: .top, spacing: 16) {
      ForEach(Status.allCases, id: \.self) { status in StatusColumn(status: status, toDos: toDos) }
    }.padding(12)
  }

  private let toDos: [ToDoType]

  init(toDos: [ToDoType]) { self.toDos = toDos }
}

private struct StatusColumn<ToDoType>: View where ToDoType: ToDo {
  var body: some View {
    VStack(alignment: .leading) {
      Label {
        Text(status.title).font(.system(.headline, weight: .medium)).textCase(.uppercase)
      } icon: {
        Image(systemName: "circle.fill").offset(y: -1).foregroundStyle(status.color).indicatorGlow(
          status: status
        ).imageScale(.small)
      }
      LazyVStack { ForEach(toDos) { toDo in ToDoCard(toDo: toDo) } }
    }
  }

  private let status: Status
  private let toDos: [ToDoType]

  init(status: Status, toDos: [ToDoType]) {
    self.status = status
    self.toDos = toDos
  }
}

extension View {
  fileprivate func indicatorGlow(status: Status) -> some View {
    Group {
      if case .idle = status { self } else { shadow(color: status.color.opacity(0.8), radius: 1.5) }
    }
  }
}

private enum Status: CaseIterable {
  var title: String {
    switch self {
    case .idle: "Idle"
    case .ongoing: "Ongoing"
    case .done: "Done"
    }
  }

  var color: Color {
    switch self {
    case .idle: .gray
    case .ongoing: .yellow
    case .done: .green
    }
  }

  case idle
  case ongoing
  case done
}

private struct ToDoCard<ToDoType>: View where ToDoType: ToDo {
  var body: some View {
    GroupBox {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text(toDo.title).font(.default).lineLimit(4)
          Text("Due \(toDo.deadline.formatted(.relative(presentation: .numeric)))").foregroundStyle(
            .secondary
          )
        }
        Spacer()
      }.padding(4)
    }
  }

  private let toDo: ToDoType

  init(toDo: ToDoType) { self.toDo = toDo }
}
