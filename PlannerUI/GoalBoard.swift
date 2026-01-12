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

import os
import PlannerToolkit
import SwiftUI

internal import UniformTypeIdentifiers

#Preview("Without to-dos") {
  GoalBoard(
    goal: .init(from: DemoPlanning.goals.first(where: \.toDos.isEmpty)!),
    onDidRequestToDoAddition: {},
    onDidRequestStatusChange: { _, _ in }
  )
  .padding()
}

#Preview("With to-dos") {
  GoalBoard(
    goal: .init(from: DemoPlanning.goals.first(where: { goal in !goal.toDos.isEmpty })!),
    onDidRequestToDoAddition: {},
    onDidRequestStatusChange: { _, _ in }
  )
  .padding()
  .padding(.vertical, 8)
}

/// Board view for the headline of a goal and its to-dos based on their status. Such layout is
/// inspired on that of some project management tools (e.g., Notion and Jira), which may present
/// tasks in such a progressed structure.
public struct GoalBoard: View {
  public var body: some View {
    if goal.toDos.isEmpty {
      EmptyGoalBoard(goal: goal, onDidRequestToDoAddition: onDidRequestToDoAddition)
    } else {
      GroupBox {
        PopulatedGoalBoard(toDos: goal.toDos, onDidRequestStatusChange: onToDoStatusChangeRequest)
          .padding(12)
      } label: {
        Headline(goal: goal)
          .padding(.bottom, 12)
      }
    }
  }

  /// Goal for which this board is, whose information will be displayed.
  private let goal: ReadOnlyGoal

  /// Callback called whenever a to-do is requested to be added to the ``goal``.
  private let onDidRequestToDoAddition: () -> Void

  /// Callback called whenever to-dos are requested to have their status changed to another
  /// different from their current one.
  private let onToDoStatusChangeRequest: ([ReadOnlyToDo], Status) -> Void

  /// Initializes a ``GoalBoard`` for displaying the headline and the to-dos of a given goal.
  ///
  /// - Parameters:
  ///   - goal: Goal for which the board is, whose information will be displayed.
  ///   - onDidRequestToDoAddition: Callback called whenever a to-do is requested to be added to the
  ///     `goal`.
  ///   - onToDoStatusChangeRequest: Callback called whenever to-dos are requested to have their
  ///     status changed to another different from their current one.
  public init(
    goal: ReadOnlyGoal,
    onDidRequestToDoAddition: @escaping () -> Void,
    onDidRequestStatusChange: @escaping ([ReadOnlyToDo], Status) -> Void
  ) {
    self.goal = goal
    self.onDidRequestToDoAddition = onDidRequestToDoAddition
    self.onToDoStatusChangeRequest = onDidRequestStatusChange
  }
}

/// View displayed whenever a goal contains no to-dos.
///
/// ###### Implementation notes
///
/// Some guesses are made in the implementation of the ``body``, given that it is unknown (to the
/// author) the exact spacing between the label of a group box of SwiftUI and its content. Its
/// layout is attempted to be replicated here, without the colored content background, which seems
/// to require reimplementing such view (or, more precisely, its vertical disposition solely).
private struct EmptyGoalBoard: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 18) {
      Headline(goal: goal)
      Callout {
        Button(action: onDidRequestToDoAddition) { Image(systemName: "plus") }
      } title: {
        Text("No to-dos yet!")
      } description: {
        Text("Think about the minimal steps you have to take in order to achieve this goal.")
      }
    }
  }

  /// Goal without to-dos.
  private let goal: ReadOnlyGoal

  /// Callback called whenever a to-do is requested to be added to the ``goal``. In case the request
  /// results in a de facto addition of a to-do, this view should not be displayed for the ``goal``
  /// anymore, as it will no longer be empty.
  private let onDidRequestToDoAddition: () -> Void

  /// Initializes an ``EmptyGoalBoard`` for displaying the details of a goal which has no to-dos.
  ///
  /// - Parameters:
  ///   - goal: The goal itself. No checks will be performed by this initializer, but it is expected
  ///     for this goal to not contain to-dos (i.e., `goal.toDos.isEmpty` to return `true`) in order
  ///     for this view to be displayed and such display be somewhat sensical.
  ///   - onDidRequestToDoAddition: Callback called whenever a to-do is requested to be added to the
  ///     `goal`.  In case the request results in a de facto addition of a to-do, this view should
  ///     not be displayed for the `goal` anymore, as it will no longer be empty.
  init(goal: ReadOnlyGoal, onDidRequestToDoAddition: @escaping () -> Void) {
    self.goal = goal
    self.onDidRequestToDoAddition = onDidRequestToDoAddition
  }
}

/// View which displays the headline (i.e., title and description) of a goal, with both of its
/// components laid out vertically.
///
/// Centralizing such implementation of the display of a headline here was made necessary because of
/// the limitation documented in ``EmptyBoardView``. Headline views are displayed in the two states
/// of a goal: empty and populated.
///
/// - SeeAlso: ``PopulatedGoalBoard``
private struct Headline: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(goal.title)
        .font(.system(.title, weight: .heavy))
      Text(goal.description)
        .font(.system(.headline, weight: .regular))
        .foregroundStyle(.secondary)
    }
  }

  /// Goal whose title and description will be displayed by this view.
  private let goal: ReadOnlyGoal

  /// Initializes a view for displaying the headline of a goal.
  ///
  /// - Parameter goal: Goal whose title and description will be displayed by this view.
  init(goal: ReadOnlyGoal) { self.goal = goal }
}

/// View for displaying a goal containing at least one to-do, with each of its to-dos being laid out
/// in a column of this view respective to its status. These to-dos may be dragged from where they
/// are to either other colums, which would trigger a request for changing their status to that of
/// the column to which they were moved.
private struct PopulatedGoalBoard: View {
  var body: some View {
    HStack(alignment: .top, spacing: 16) {
      ForEach(Status.allCases, id: \.self) { status in
        StatusColumn(
          status: status,
          toDos: toDos,
          onDidRequestStatusChange: onDidRequestStatusChange
        )
      }
    }
  }

  /// Non-empty array of to-dos of a goal.
  private let toDos: [ReadOnlyToDo]

  /// Callback called whenever to-dos are requested to have their status changed to another
  /// different from their current one.
  private let onDidRequestStatusChange: (_ toDos: [ReadOnlyToDo], _ newStatus: Status) -> Void

  /// Initializes a view which displays the to-dos of a goal in columns respective to the status of
  /// such to-dos.
  ///
  /// - Parameters:
  ///   - toDos: Non-empty array of to-dos of the goal. This initializer does not check
  ///     whether the array is, in fact, empty, as this condition is assumed to already be satisfied
  ///     and have been asserted against by the caller. For goals without to-dos, display an
  ///     ``EmptyGoalBoard`` (outside of the group box inside which a populated board should be)
  ///     instead.
  ///   - onDidRequestStatusChange: Callback called whenever to-dos are requested to have their
  ///     status changed to another different from their current one. These to-dos may be from a
  ///     goal other than that to which they belonged previously.
  init(toDos: [ReadOnlyToDo], onDidRequestStatusChange: @escaping ([ReadOnlyToDo], Status) -> Void)
  {
    self.toDos = toDos
    self.onDidRequestStatusChange = onDidRequestStatusChange
  }
}

/// One of the three columns rendered by a ``PopulatedGoalBoard``, pertaining to the status of
/// completion of a to-do of a goal. Vertically displays a label for the status and the to-dos
/// whose status is such.
private struct StatusColumn: View {
  var body: some View {
    VStack(alignment: .leading) {
      StatusLabel(status: status)
      VStack {
        ForEach(Array(zip(toDos.indices, toDos)), id: \.1.id) { index, toDo in
          withDropDestinationIndication(
            forCardOf: toDo,
            isFirstCard: index == toDos.startIndex,
            indicatorAbsoluteYOffset: { position in
              // This is just a guess for the half of the SwiftUI-defined amount of points
              // separating each view, which is unknown by the author.
              index == toDos.startIndex && position == .before ? 4 : 1.5
            }
          ) {
            ToDoCard(toDo: toDo)
              .draggable(toDo)
              .onGeometryChange(for: CGRect.self) { geometry in
                geometry.frame(in: .global)
              } action: { toDoCardFrame in
                if let frame, frame.intersects(toDoCardFrame) {
                  toDoCardFraming[toDo] = toDoCardFrame
                } else {
                  toDoCardFraming.removeValue(forKey: toDo)
                }
              }
          }
        }
      }
      .dropDestination(for: ReadOnlyToDo.self) { droppedToDos, _ in
        onDidRequestStatusChange(droppedToDos, status)
        return true
      }
      .onDropSessionUpdated { session in
        switch session.phase {
        case .entering, .active:
          guard let frame else { return }
          toDoCardDragLocation = .init(
            x: frame.minX + session.location.x,
            y: frame.minY + session.location.y
          )
        case .exiting, .ended(_), .dataTransferCompleted: toDoCardDragLocation = nil
        @unknown default: ()
        }
      }
    }
    .onGeometryChange(for: CGRect.self) { geometry in
      geometry.frame(in: .global)
    } action: { frame in
      self.frame = frame
    }
  }

  /// Rectangle of this ``StatusColumn`` the in global coordinate space. Starts off `nil` and gets
  /// set upon display of this column.
  @State
  private var frame: CGRect?

  /// Relation between each of the `toDos` and the frame of its card in the coordinate space of
  /// either the global coordinate space. This dictionary is empty by default, and gets populated
  /// according to the appearance of each card; entries are removed whenever the card of the
  /// respective to-do is made invisible.
  @State
  private var toDoCardFraming = [ReadOnlyToDo: CGRect]()

  /// Point in the global coordinate space at which to-dos being dragged from some ``StatusColumn``
  /// (which may be the same one in which they already were) are at the moment. `nil` when no
  /// drag-and-drop session is taking place or the to-dos being draggered are not hovering existing
  /// ones.
  @State
  private var toDoCardDragLocation: CGPoint?

  /// Status for which this column is. Because the to-dos themselves are provided by the caller of
  /// the initializer of this column, this property merely influcences the label to be displayed
  /// above the list of cards of to-dos.
  private let status: Status

  /// Subset of to-dos of a goal, whose status is that of this column.
  private let toDos: [ReadOnlyToDo]

  /// Callback called whenever to-dos are requested to have their status changed to another
  /// different from their current one.
  private let onDidRequestStatusChange: (_ toDos: [ReadOnlyToDo], _ newStatus: Status) -> Void

  /// Height of the indicator rendered whenever to-dos are being dragged from one ``StatusColumn``
  /// into another, communicating the position at which they will be placed in the destination
  /// column after such drag-and-drop session.
  private static let toDoCardDropDestinationIndicatorHeight: CGFloat = 2

  /// Description of the location at which to-dos being dropped into another ``StatusColumn`` would
  /// be placed relative to the position of a given to-do already at that column. Because there is
  /// no actual implementation of custom ordering of to-dos of a goal yet, this is a mere visual
  /// detail.
  private enum ToDoCardPredictedDropPosition {
    /// To-dos have been dragged from their ``StatusColumn`` and are hovering another column. These
    /// to-dos, if dropped, would be placed before the to-do to which this position is relative.
    case before

    /// To-dos have been dragged from their ``StatusColumn`` and are hovering another column. These
    /// to-dos, if dropped, would be placed after the to-do to which this position is relative.
    case after
  }

  /// Initializes a view which lays out the to-dos with a given status.
  ///
  /// - Parameters:
  ///   - status: Status for which this column is, in which the `toDos` are.
  ///   - toDos: Subset of to-dos of a goal, whose status is that of the column. The status of these
  ///     to-dos will not be checked by this initializer; therefore, it is implicit that theirs and
  ///     the status of this column do, indeed, match.
  ///   - onDidRequestStatusChange: Callback called whenever to-dos are requested to have their
  ///     status changed to another different from their current one.
  init(
    status: Status,
    toDos: [ReadOnlyToDo],
    onDidRequestStatusChange: @escaping (_ toDos: [ReadOnlyToDo], _ newStatus: Status) -> Void
  ) {
    self.status = status
    self.toDos = toDos
    self.onDidRequestStatusChange = onDidRequestStatusChange
  }

  /// Provides the given `content` with an overlay indicating the position at which to-dos being
  /// dragged in a drag-and-drop session would be placed in the column in which the `toDo` is.
  /// Custom sorting of to-dos is not an implemented feature yet; therefore, this is a mere visual
  /// effect for now. If no drag-and-drop session is ongoing, the `content` is laid out unchanged.
  ///
  /// - Parameters:
  ///   - toDo: To-do whose card is being hovered by the to-dos being dragged.
  ///   - isFirstCard: Whether the card of the `toDo` is the first one in the layout stack.
  ///   - calculateMainAxisIndicatorAbsoluteOffset: Produces the amount of points by which the
  ///     destination indicator will be offset in the Y-axis.
  /// - Returns: The `content` itself in case no drag-and-drop session is ongoing; otherwise, the
  ///   the `content` overlaid by an indicator for the destination of the to-dos being dragged in
  ///   the session.
  @ViewBuilder
  private func withDropDestinationIndication(
    forCardOf toDo: ReadOnlyToDo,
    isFirstCard: Bool,
    indicatorAbsoluteYOffset calculateIndicatorAbsoluteYOffset: (
      ToDoCardPredictedDropPosition
    ) ->
      CGFloat,
    @ViewBuilder content: () -> some View
  ) -> some View {
    if let dragLocation = toDoCardDragLocation,
      let toDoCardFrame = toDoCardFraming[toDo],
      toDoCardFrame.contains(dragLocation)
    {
      let position =
        isFirstCard && dragLocation.y < toDoCardFrame.minY + toDoCardFrame.height / 2
        ? ToDoCardPredictedDropPosition.before : .after
      let absoluteYOffset =
        (position == .before ? 0 : toDoCardFrame.height)
        + Self.toDoCardDropDestinationIndicatorHeight
        + calculateIndicatorAbsoluteYOffset(position)
      let yOffset =
        switch position {
        case .before: -absoluteYOffset
        case .after: absoluteYOffset
        }
      content()
        .overlay(alignment: .top) {
          LinearGradient(
            colors: [.clear, .init(nsColor: .controlAccentColor), .clear],
            startPoint: .leading,
            endPoint: .trailing
          )
          .frame(width: toDoCardFrame.width, height: Self.toDoCardDropDestinationIndicatorHeight)
          .offset(y: yOffset)
        }
    } else {
      content()
    }
  }
}

/// View which displays an indicator and the title of a given status of a to-do horizontally. This
/// label differentiates the column for which it is from those rendered for other statuses, and is
/// displayed above the to-dos whose status is that for which such column is.
private struct StatusLabel: View {
  var body: some View {
    Label {
      Text(status.title)
        .font(.system(.headline, weight: .medium))
        .textCase(.uppercase)
    } icon: {
      Image(systemName: "circle.fill")
        .offset(y: -1)
        .foregroundStyle(status.color)
        .shadow(
          color: status == .idle ? .clear : status.color.opacity(0.8),
          radius: status == .idle ? 0 : 1.5
        )
        .imageScale(.small)
    }
  }

  /// Status for which this label is. In all labels of such kind, the style of the title remains
  /// unchanged; what changes depending on this status is the indicator, which will be colored
  /// differently; and glow in case this is not the idle status.
  ///
  /// - SeeAlso: ``Status/idle``
  private let status: Status

  /// Initializes a label for a given status.
  ///
  /// - Parameter status: Status for which this label is. In all labels of such kind, the style of
  ///   the title remains unchanged; what changes depending on this status is the indicator, which
  ///   will be colored differently; and glow in case this is not the idle status.
  init(status: Status) { self.status = status }
}

/// Stage of completion of a to-do, denoting whether it is *idle*, *ongoing* or *done*. For each
/// status, a column is drawn in the ``GoalBoard``, from which each of the to-dos with such status
/// can be dragged onto the column of another status and be requested to have its own status changed
/// to that of such column to which it was moved.
///
/// ## Disclaimer
///
/// This is part of PlannerUI temporarily; instead, a status will be a property of every to-do in
/// the domain layer. As of now, because to-dos are binarily deemed "not done" or "done", they are
/// repeated in each column respective to each status in a board.
public enum Status: CaseIterable {
  /// General, short and displayable description of this ``Status``.
  var title: String {
    switch self {
    case .idle: "Idle"
    case .ongoing: "Ongoing"
    case .done: "Done"
    }
  }

  /// Color by which this status is represented. Used for coloring the indicator beside the title in
  /// the label of a ``StatusColumn``.
  var color: Color {
    switch self {
    case .idle: .gray
    case .ongoing: .yellow
    case .done: .green
    }
  }

  /// Denotes that the to-do has been added to the goal, but no progress on it has been done yet.
  case idle

  /// Denotes that the to-do is being worked on and is not yet done.
  case ongoing

  /// Denotes that the to-do has been worked on and is done.
  case done
}

extension ReadOnlyToDo: Transferable {
  public static var transferRepresentation: some TransferRepresentation {
    CodableRepresentation(contentType: .propertyList).visibility(.ownProcess)
  }
}

/// Card of a to-do in a ``GoalBoard``, in which the title of such to-do and the time remaining for
/// its deadline or since which it was done is displayed.
private struct ToDoCard: View {
  var body: some View {
    GroupBox {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text(toDo.title)
            .font(.default)
            .lineLimit(4)
          Text("Due \(toDo.deadline.formatted(.relative(presentation: .numeric)))")
            .foregroundStyle(.secondary)
        }
        Spacer()
      }
      .padding(4)
    }
  }

  /// To-do whose information will be displayed.
  private let toDo: ReadOnlyToDo

  /// Initializes a card for a to-do.
  ///
  /// - Parameter toDo: To-do whose information will be displayed.
  init(toDo: ReadOnlyToDo) { self.toDo = toDo }
}
