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

private let goalTitle = "Simulate the Big Bang"
private let goalDescription =
  "Develop a computer simulation for the origin of the Universe emergently."

#Preview("Without to-dos") {
  GoalBoard(goal: DemoGoal(title: goalTitle, description: goalDescription)).padding()
}

#Preview("With to-dos") {
  GoalBoard(
    goal: DemoGoal(
      title: goalTitle,
      description: goalDescription,
      toDos: [
        .init(
          title: "Know kindergarden-level mathematics",
          description: "",
          deadline: .distantFuture
        ), .init(title: "Study the basics of physics", description: "", deadline: .distantFuture)
      ]
    )
  ).padding().padding(.vertical, 16)
}

public struct GoalBoard<GoalType>: View where GoalType: Goal {
  private let goal: GoalType

  public var body: some View {
    GroupBox {
      if goal.toDos.isEmpty {
        EmptyToDoBoard().frame(maxWidth: .infinity).padding()
      } else {
        PopulatedToDoBoard(toDos: goal.toDos)
      }
    } label: {
      Headline(goal: goal).padding(.bottom, 12)
    }
  }

  init(goal: GoalType) { self.goal = goal }
}

private struct PopulatedToDoBoard<ToDoType: ToDo>: View where ToDoType: ToDo {
  private let toDos: [ToDoType]

  var body: some View {
    HStack(alignment: .top, spacing: 16) {
      ForEach(Status.allCases, id: \.self) { status in StatusColumn(status: status, toDos: toDos) }
    }.padding(12)
  }

  init(toDos: [ToDoType]) { self.toDos = toDos }
}

private struct StatusColumn<ToDoType>: View where ToDoType: ToDo {
  private let stage: Status
  private let toDos: [ToDoType]

  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Circle().frame(width: 4).foregroundStyle(stage.color)
        Text(stage.title).frame(width: .infinity).font(.system(.headline, weight: .medium))
          .textCase(.uppercase)
      }
      LazyVStack { ForEach(toDos) { toDo in ToDoCard(toDo: toDo) } }
    }
  }

  init(status: Status, toDos: [ToDoType]) {
    self.stage = status
    self.toDos = toDos
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
  private let toDo: ToDoType

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

  init(toDo: ToDoType) { self.toDo = toDo }
}

private struct EmptyToDoBoard: View {
  var body: some View {
    HStack(spacing: 24) {
      Image(systemName: "lightbulb.max.fill").imageScale(.large)
      VStack(alignment: .leading, spacing: 4) {
        Text("No to-dos yet!").font(.system(.headline, weight: .medium))
        Text("Think about the minimal steps you have to take in order to achieve this goal.")
      }
      Spacer()
      Button {
      } label: {
        ZStack { Image(systemName: "plus") }
      }.buttonStyle(.glass)
    }.foregroundStyle(.secondary)
  }
}

private struct Headline<GoalType>: View where GoalType: Goal {
  private let goal: GoalType

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(goal.title).font(.system(.title, weight: .heavy))
      Text(goal.description).font(.system(.headline, weight: .regular)).foregroundStyle(.secondary)
    }
  }

  init(goal: GoalType) { self.goal = goal }
}
