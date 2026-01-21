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
import SwiftUI

internal import Collections

#Preview("Without to-dos") {
  GoalBoard(
    goal: .init(from: Planning.demo.goals.first(where: \.toDos.isEmpty)!),
    onDidRequestToDoAddition: {},
    onDidRequestStatusChange: { _, _ in }
  )
  .padding()
}

#Preview("With to-dos", traits: .sizeThatFitsLayout) {
  GoalBoard(
    goal: .init(from: Planning.demo.goals.first(where: { goal in !goal.toDos.isEmpty })!),
    onDidRequestToDoAddition: {},
    onDidRequestStatusChange: { _, _ in }
  )
  .padding()
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
  private let onToDoStatusChangeRequest: (_ toDos: [ReadOnlyToDo], _ newStatus: Status) -> Void

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
    onDidRequestStatusChange: @escaping (_ toDos: [ReadOnlyToDo], _ newStatus: Status) -> Void
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
      Text(goal.summary)
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
private struct PopulatedGoalBoard<ToDos>: View
where ToDos: RandomAccessCollection & Sendable, ToDos.Element == ReadOnlyToDo {
  var body: some View {
    HStack(alignment: .top) {
      ForEach(completion.keys, id: \.self) { status in
        StatusColumn(
          status: status,
          toDos: completion[status] ?? [],
          onDidRequestStatusChange: { toDos in onDidRequestStatusChange(toDos, status) }
        )
      }
    }
  }

  /// Relation between all statuses and to-dos from the array passed into the initializer of this
  /// board whose statuses match that to which they are associated. This dictionary is sorted when
  /// set; therefore, the keys are *idle*, *ongoing* and *done*, in this order, regardless of
  /// whether to-dos with the status were given (in this case, the value will be an empty array).
  private let completion: OrderedDictionary<Status, [ReadOnlyToDo]>

  /// Non-empty collection of to-dos of a goal.
  private let toDos: ToDos

  /// Callback called whenever to-dos are requested to have their status changed to another
  /// different from their current one.
  private let onDidRequestStatusChange: (_ toDos: [ReadOnlyToDo], _ newStatus: Status) -> Void

  /// Initializes a view which displays the to-dos of a goal in columns respective to the status of
  /// such to-dos.
  ///
  /// - Parameters:
  ///   - toDos: Non-empty collection of to-dos of the goal. This initializer does not check
  ///     whether the array is, in fact, empty, as this condition is assumed to already be satisfied
  ///     and have been asserted against by the caller. For goals without to-dos, display an
  ///     ``EmptyGoalBoard`` (outside of the group box inside which a populated board should be)
  ///     instead.
  ///   - onDidRequestStatusChange: Callback called whenever to-dos are requested to have their
  ///     status changed to another different from their current one.
  init(
    toDos: ToDos,
    onDidRequestStatusChange: @escaping (_ toDos: [ReadOnlyToDo], _ newStatus: Status) -> Void
  ) {
    self.toDos = toDos
    var completion = OrderedDictionary(grouping: toDos, by: \.status)
    completion.sort()
    self.completion = completion
    self.onDidRequestStatusChange = onDidRequestStatusChange
  }
}

/// One of the three columns rendered by a ``PopulatedGoalBoard``, pertaining to the status of
/// completion of a to-do of a goal. Vertically displays a label for the status and the to-dos
/// whose status is such.
private struct StatusColumn<ToDos>: View
where ToDos: RandomAccessCollection & Sendable, ToDos.Element == ReadOnlyToDo {
  var body: some View {
    VStack {
      ForEach(ToDoCardDropIndicatorTarget.allCases(for: toDos)) { target in
        withDropDestinationIndication(for: target) {
          switch target {
          case .label(_):
            StatusLabel(status: status)
              .frame(maxWidth: .infinity, alignment: .topLeading)
              .onGeometryChange(for: CGRect.self) { geometry in
                geometry.frame(in: .global)
              } action: { frame in
                labelFrame = frame
              }
          case .toDoCard(let toDo, _, _):
            ToDoCard(toDo: toDo)
              .draggable(toDo)
              .onGeometryChange(for: CGRect?.self) { geometry in
                geometry.frame(in: .global)
              } action: { toDoCardFrame in
                if let frame, let toDoCardFrame, frame.intersects(toDoCardFrame) {
                  toDoCardFraming[toDo] = toDoCardFrame
                } else {
                  toDoCardFraming.removeValue(forKey: toDo)
                }
              }
          }
        }
      }
    }
    .dropDestination(for: ReadOnlyToDo.self) { droppedToDos, _ in
      onDidRequestStatusChange(droppedToDos)
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

  /// Rectangle of the label preceding the to-dos in this column in the global coordinate space.
  /// Is initially `nil` and set when this column is displayed.
  @State
  private var labelFrame: CGRect?

  /// Relation between each of the `toDos` and the frame of its card in the global coordinate space.
  /// This dictionary is empty by default, and gets populated according to the appearance of each
  /// card; entries are removed whenever the card of the respective to-do is made invisible.
  @State
  private var toDoCardFraming = [ReadOnlyToDo: CGRect]()

  /// Point in the global coordinate space at which to-dos being dragged from some ``StatusColumn``
  /// (which may be the same one in which they already were) are at the moment. `nil` when no
  /// drag-and-drop session is taking place or the to-dos being dragged are not hovering existing
  /// ones.
  @State
  private var toDoCardDragLocation: CGPoint?

  /// Status for which this column is. Because the to-dos themselves are provided by the caller of
  /// the initializer of this column, this property merely influcences the label to be displayed
  /// above the list of cards of to-dos.
  private let status: Status

  /// Subset of to-dos of a goal, whose status is that of this column.
  private let toDos: ToDos

  /// Callback called whenever to-dos are requested to have their status changed to that of this
  /// column.
  private let onDidRequestStatusChange: (_ toDos: [ReadOnlyToDo]) -> Void

  /// Height of the indicator rendered whenever to-dos are being dragged from one ``StatusColumn``
  /// into another, communicating the position at which they will be placed in the destination
  /// column after such drag-and-drop session.
  private static var toDoCardDropDestinationIndicatorHeight: CGFloat { 2 }

  /// Node of a linked-list-like data structure which indicates the view onto which an indicator
  /// for communicating the position at which to-dos being dragged in a drag-and-drop session would
  /// be placed in relation to such view (either above or below it).
  private indirect enum ToDoCardDropIndicatorTarget: Hashable, Identifiable {
    var id: AnyHashable {
      switch self {
      case .label(_): self
      case .toDoCard(let toDo, _, _): toDo.id
      }
    }

    /// Target by which this one is anteceded in the sequence.
    private var previous: Self? {
      switch self {
      case .label(_): nil
      case .toDoCard(_, let previous, _): previous
      }
    }

    /// Whether this target is the only one in the sequence, i.e., is both the first and the last
    /// one, for which ``isLast`` returns `true`.
    private var isSingle: Bool {
      switch self {
      case .label(let isLast): isLast
      case .toDoCard(_, _, _): false
      }
    }

    /// Whether this target is the last in the sequence.
    private var isLast: Bool {
      switch self {
      case .label(let isLast): isLast
      case .toDoCard(_, _, let isLast): isLast
      }
    }

    /// Target of the ``StatusLabel`` of a column.
    ///
    /// - Parameter isLast: Whether the sequence is not followed by targets of to-do cards.
    /// - SeeAlso: ``toDoCard(toDo:previous:isLast:)``
    case label(isLast: Bool)

    /// Target of a ``ToDoCard`` in a column.
    ///
    /// - Parameters:
    ///   - toDo: To-do whose card is the view of this target.
    ///   - previous: Target before this one in the sequence. This being ``label(isLast:)`` means
    ///     that the card is the first being displayed.
    ///   - isLast: Whether the card is the last in the sequence.
    /// - SeeAlso: ``allCases(for:)``
    case toDoCard(toDo: ReadOnlyToDo, previous: Self, isLast: Bool)

    /// Calculates the amount of points by which the indicator should be offset vertically, with the
    /// minimum coordinate in the Y-axis of the view of this target as the origin. Applying it to
    /// the indicator positions it below the target after which the to-dos being dragged would be
    /// placed if dropped.
    ///
    /// - Parameter parent: Column responsible for rendering the view.
    /// - Returns: The offset in the Y-axis for the indicator, or `nil` any of the required views
    ///   are not being displayed by the `parent`.
    @MainActor
    func indicatorOffset(in parent: StatusColumn) -> CGFloat? {
      guard let reference = reference(in: parent) else { return nil }
      guard reference == self else { return reference.spacing(in: parent)?.scaled(by: -1) }
      guard let frame = reference.frame(in: parent) else { return nil }
      return frame.height
    }

    /// Obtains the target after which the indicator should be displayed, which may be this target
    /// or that which antecedes it. The resulting target is considered the reference one based on
    /// the location over which the to-do cards are being dragged during a drag-and-drop session.
    ///
    /// - Parameter parent: Column responsible for rendering the view.
    /// - Returns: The reference target; or `nil` if any of the required views (mandatorily
    ///   including the `parent`, and may also include the view of this target or that of the
    ///   ``previous`` target) are not being displayed.
    @MainActor
    private func reference(in parent: StatusColumn) -> Self? {
      guard let dragLocation = parent.toDoCardDragLocation,
        let parentFrame = parent.frame,
        parentFrame.contains(dragLocation),
        let frame = frame(in: parent)
      else { return nil }
      return
        if dragLocation.y < frame.midY,
        let previous,
        let previousFrame = previous.frame(in: parent),
        dragLocation.y > previousFrame.midY
      {
        previous
      } else if dragLocation.y < frame.maxY, dragLocation.y > frame.midY {
        self
      } else {
        nil
      }
    }

    /// Calculates the spacing between the view of this target and either that of the next target or
    /// the maximum coordinate of the given column in the Y-axis in case no other target follows
    /// this one in the sequence.
    ///
    /// - Parameter parent: Column responsible for rendering the view.
    /// - Returns: The spacing, or `nil` if the view of this target or that of the ``previous`` one
    ///   is not being displayed while this target is neither single nor the last in the sequence.
    /// - SeeAlso: ``isSingle``
    /// - SeeAlso: ``isLast``
    @MainActor
    private func spacing(in parent: StatusColumn) -> CGFloat? {
      guard let frame = frame(in: parent) else { return nil }
      guard !isSingle else {
        return if let parentFrame = parent.frame { frame.minY - parentFrame.minY } else { nil }
      }
      guard !isLast else {
        return if let parentFrame = parent.frame { parentFrame.maxY - frame.maxY } else { nil }
      }
      guard let previousFrame = previous?.frame(in: parent) else { return nil }
      return frame.minY - previousFrame.maxY
    }

    /// Obtains the rectangle of this target in the global coordinate space.
    ///
    /// - Parameter parent: Column responsible for rendering the view.
    /// - Returns: The frame, or `nil` if the view is not being displayed.
    @MainActor
    private func frame(in parent: StatusColumn) -> CGRect? {
      switch self {
      case .label(_): parent.labelFrame
      case .toDoCard(let toDo, _, _): parent.toDoCardFraming[toDo]
      }
    }

    /// Produces an array containing one target for every to-do in a given collection. The
    /// predecessor of the second target in the returned array is the label target; that of a target
    /// after the second one is the to-do card target produced before it.
    ///
    /// - Parameter toDos: To-dos for which targets will be produced.
    /// - SeeAlso: ``label(isLast:)``
    static func allCases(for toDos: some RandomAccessCollection<ReadOnlyToDo>) -> [Self] {
      let count = toDos.count + 1
      return unsafe [Self](unsafeUninitializedCapacity: count) { buffer, initializedCount in
        guard var address = buffer.baseAddress else { return }
        var previousTarget = Self.label(isLast: toDos.isEmpty)
        unsafe address.initialize(to: previousTarget)
        unsafe address = address.successor()
        for toDo in toDos {
          let currentTarget = Self.toDoCard(
            toDo: toDo,
            previous: previousTarget,
            isLast: toDo == toDos.last
          )
          unsafe address.initialize(to: currentTarget)
          previousTarget = currentTarget
          unsafe address = address.successor()
        }
        initializedCount = count
      }
    }
  }

  /// Initializes a view which lays out the to-dos with a given status.
  ///
  /// - Parameters:
  ///   - status: Status for which this column is, in which the `toDos` are.
  ///   - toDos: Subset of to-dos of a goal, whose status is that of the column. The status of these
  ///     to-dos will not be checked by this initializer; therefore, it is implicit that theirs and
  ///     the status of this column do, indeed, match.
  ///   - onDidRequestStatusChange: Callback called whenever to-dos are requested to have their
  ///     status changed to that of this column.
  init(
    status: Status,
    toDos: ToDos,
    onDidRequestStatusChange: @escaping ([ReadOnlyToDo]) -> Void
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
  ///   - target: Indicates which view the `content` is, allowing for adapting the display of the
  ///     indicator (e.g., its position) in relation to the views in the column.
  /// - Returns: The `content` itself in case no drag-and-drop session is ongoing; otherwise, the
  ///   the `content` overlaid by an indicator for the destination of the to-dos being dragged in
  ///   the session.
  @ViewBuilder
  private func withDropDestinationIndication(
    for target: ToDoCardDropIndicatorTarget,
    @ViewBuilder content: () -> some View
  ) -> some View {
    if let indicatorOffset = target.indicatorOffset(in: self) {
      content()
        .overlay(alignment: .top) {
          LinearGradient(
            colors: [.clear, .init(nsColor: .controlAccentColor), .clear],
            startPoint: .leading,
            endPoint: .trailing
          )
          .frame(height: Self.toDoCardDropDestinationIndicatorHeight)
          .offset(y: indicatorOffset)
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

extension Status {
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
